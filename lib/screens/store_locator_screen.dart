import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nashr/widgets/loader.dart';

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  late MapboxMap _mapboxMap;
  LocationData? _currentLocation;
  final Location _location = Location();
  String _address = '';
  String _city = '';
  double? _selectedLat;
  double? _selectedLng;
  PointAnnotationManager? _pointAnnotationManager;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.selectStoreLocation,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done, color: Colors.green),
            onPressed: _selectedLat != null && _selectedLng != null
                ? () {
              Navigator.pop(context, {
                'lat': _selectedLat.toString(),
                'lng': _selectedLng.toString(),
                'address': _address,
                'city': _city,
              });
            }
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapUp: (TapUpDetails details) {
              _handleMapTap(details.localPosition);
            },
            child: SizedBox.expand(
              child: MapWidget(
                androidHostingMode: AndroidPlatformViewHostingMode.HC,
                styleUri: MapboxStyles.STANDARD,
                onMapCreated: (controller) async {
                  _mapboxMap = controller;
                  _pointAnnotationManager = await _mapboxMap.annotations.createPointAnnotationManager();
                },
              ),
            ),
          ),

          if (_address.isNotEmpty)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.locationSelected,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _address,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      if (_city.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.city}: $_city',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Loader(),
                ),
              ),
            ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'current_location_fab',
                  backgroundColor: Colors.white,
                  onPressed: _moveToCurrentLocation,
                  tooltip: 'Move to current location',
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle map tap
  Future<void> _handleMapTap(Offset position) async {
    try {
      final screenCoordinate = ScreenCoordinate(
        x: position.dx,
        y: position.dy,
      );
      final coordinate = await _mapboxMap.coordinateForPixel(screenCoordinate);
      _onLocationSelected(coordinate.coordinates.lat.toDouble(), coordinate.coordinates.lng.toDouble());
        } catch (e) {
      print('Error handling map tap: $e');
    }
  }

  /// Helper methods
  void _moveToCurrentLocation() async {
    if (_currentLocation != null) {
      await _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
      _onLocationSelected(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.currentLocation,
            style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.black
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.currentLocationNotAvailable,
            style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null) {
        await _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
        _onLocationSelected(_currentLocation!.latitude!, _currentLocation!.longitude!);
      }
    }
  }

  Future<void> _moveToLocation(double latitude, double longitude) async {
    await _mapboxMap.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 15.0,
      ),
      MapAnimationOptions(
        duration: 1000,
      ),
    );
  }

  void _onLocationSelected(double latitude, double longitude) async {
    setState(() {
      _selectedLat = latitude;
      _selectedLng = longitude;
    });
    await _addMarker(latitude, longitude);

    await _getAddressFromCoordinates(latitude, longitude);
  }

  Future<void> _addMarker(double latitude, double longitude) async {
    if (_pointAnnotationManager == null) return;

    try {
      await _pointAnnotationManager!.deleteAll();

      final ByteData bytes = await rootBundle.load('images/placeholder.png');
      final Uint8List list = bytes.buffer.asUint8List();

      // Create new marker
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(longitude, latitude)),
        image: list,
        iconSize: 0.2,
      );

      await _pointAnnotationManager!.create(pointAnnotationOptions);
    } catch (e) {
      print('Error adding marker: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    setState(() {
      _isLoading = true;
    });

    try {
      const String accessToken = 'pk.eyJ1IjoibmFzdGVjc29sIiwiYSI6ImNtMm9qc3lzMTBnamMya3F6cmJsbWZ5MmsifQ.ExjMBEpuTJDstkVQTPeJTA';

      final url = Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$accessToken'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          setState(() {
            _address = feature['place_name'] ?? '';
            if (feature['context'] != null) {
              for (var context in feature['context']) {
                if (context['id'].toString().startsWith('place.')) {
                  _city = context['text'] ?? '';
                  break;
                }
              }
            }
            if (_city.isEmpty && feature['place_type'] != null) {
              if (feature['place_type'].contains('place')) {
                _city = feature['text'] ?? '';
              }
            }
          });
        }
      } else {
        print('Failed to get address: ${response.statusCode}');
        setState(() {
          _address = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
          _city = '';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _address = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
        _city = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}