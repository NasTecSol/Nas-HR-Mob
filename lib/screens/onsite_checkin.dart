import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:locale_plus/locale_plus.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/attendance_model.dart';
import 'package:nashr/widgets/loader.dart';

class OnsiteCheckin extends StatefulWidget {
  const OnsiteCheckin({super.key});

  @override
  State<OnsiteCheckin> createState() => _OnsiteCheckinState();
}

class _OnsiteCheckinState extends State<OnsiteCheckin> {
  SingletonClass singletonClass = SingletonClass();
  bool isCheckedIn = false;
  bool isCheckedOut = false;
  bool isLoading = false;
  bool isWithinRadius = false;
  late MapboxMap _mapboxMap;
  LocationData? _currentLocation;
  final Location _location = Location();
  PointAnnotationManager? _pointAnnotationManager;
  CircleAnnotationManager? _circleAnnotationManager;
  bool _showCheckInCard = true;
  final double _radiusInMeters = 100.0;
  double? _companyLatitude;
  double? _companyLongitude;

  @override
  void initState() {
    super.initState();
    _parseCompanyLocation();
    _loadMapState();
    _getCurrentLocation();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showCheckInCard = false;
        });
      }
    });
  }

  void _parseCompanyLocation() {
    final String? locString = singletonClass.remoteAttendanceModelList.isNotEmpty &&
        singletonClass.remoteAttendanceModelList.first.data!.isNotEmpty &&
        singletonClass.remoteAttendanceModelList.first.data!.first.remoteAttendanceLoc!.isNotEmpty
        ? singletonClass.remoteAttendanceModelList.first.data!.first.remoteAttendanceLoc
        : null;

    if (locString != null && locString.contains('|')) {
      final parts = locString.split('|');
      if (parts.length == 2) {
        _companyLatitude = double.tryParse(parts[0].trim()) ?? 0.0;
        _companyLongitude = double.tryParse(parts[1].trim()) ?? 0.0;
      }
    }
  }

  Future<void> _loadMapState() async {
    final today = DateTime.now();
    final dataList = singletonClass.attendanceDataList.first.data?.data ?? [];
    Data1? todayData;
    for (var entry in dataList) {
      final createdAt = DateTime.tryParse(entry.createdAt ?? '');
      if (createdAt != null &&
          createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day) {
        todayData = entry;
        break;
      }
    }

    final checkInTime = todayData?.clockInTime;
    final checkOutTime = todayData?.clockOutTime;
    setState(() {
      isCheckedIn = checkInTime != null && checkInTime.isNotEmpty && checkInTime == '' ;
      isCheckedOut = checkOutTime != null && checkOutTime.isNotEmpty && checkOutTime == '';
    });
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null) {
        await _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
        await _addCurrentLocationMarker(_currentLocation!);
        await _addCompanyLocationMarker();
        _checkProximityToCompanyLocation();
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

  Future<void> _addCurrentLocationMarker(LocationData locationData) async {
    try {
      final ByteData bytes = await rootBundle.load('images/placeholder.png');
      final Uint8List list = bytes.buffer.asUint8List();

      _pointAnnotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(locationData.longitude!, locationData.latitude!)),
        image: list,
        iconSize: 0.2,
      );
      await _pointAnnotationManager!.create(pointAnnotationOptions);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding current location marker: $e');
      }
    }
  }

  void _checkProximityToCompanyLocation() {
    if (_currentLocation != null && _companyLatitude != null && _companyLongitude != null) {
      final double distance = _calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        _companyLatitude!,
        _companyLongitude!,
      );

      setState(() {
        isWithinRadius = distance <= _radiusInMeters;
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  Future<void> _addCompanyLocationMarker() async {
    if (_companyLatitude == null || _companyLongitude == null) return;

    try {
      final ByteData bytes = await rootBundle.load('images/site.png');
      final Uint8List list = bytes.buffer.asUint8List();

      final pointAnnotationManager = await _mapboxMap.annotations.createPointAnnotationManager();
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude!, _companyLatitude!)),
        image: list,
        iconSize: 0.5,
      );
      await pointAnnotationManager.create(pointAnnotationOptions);

      _circleAnnotationManager = await _mapboxMap.annotations.createCircleAnnotationManager();
      final circleAnnotationOptions = CircleAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude!, _companyLatitude!)),
        circleRadius: _radiusInMeters / 100,
        circleColor: 0x0000FF,
        circleOpacity: 0.3,
        circleStrokeColor: 0x0000FF,
        circleStrokeWidth: 1.0,
      );
      await _circleAnnotationManager!.create(circleAnnotationOptions);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding company location marker: $e');
      }
    }
  }

  Future<void> _moveToCompanyLocation() async {
    if (_companyLatitude != null && _companyLongitude != null) {
      await _moveToLocation(_companyLatitude!, _companyLongitude!);
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }
  }

  void _handleCheckInOut() {
    if (isWithinRadius) {
      checkIn("location");
    }
  }

  String _getAppBarTitle() {
    if (isCheckedIn) {
      return AppLocalizations.of(context)!.checkOut;
    } else if (!isWithinRadius) {
      return AppLocalizations.of(context)!.outOfRadiusRange;
    } else if (isCheckedOut){
      return AppLocalizations.of(context)!.checkIn;
    } else {
      return AppLocalizations.of(context)!.clockIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isWithinRadius || isCheckedIn || isCheckedOut ? Colors.black : Colors.red,
          ),
        ),
        actions: [
          if(isWithinRadius)
          IconButton(
            icon: Icon(
              (isCheckedIn) ? Icons.logout : Icons.done,
              color: (isCheckedIn) ? Colors.red : Colors.green,
            ),
            onPressed: (isCheckedIn) ? _handleCheckInOut : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: MapWidget(
              androidHostingMode: AndroidPlatformViewHostingMode.HC,
              styleUri: MapboxStyles.STANDARD,
              onMapCreated: (controller) {
                setState(() {
                  _mapboxMap = controller;
                });
              },
            ),
          ),
          if (!isWithinRadius && _currentLocation != null)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Card(
                color: Colors.red.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.locationAttendanceRangeInfo,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isCheckedIn && _showCheckInCard)
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Card(
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.checkInComplete}. Tap on out button to check out.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isLoading)
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
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  heroTag: 'company_location_fab',
                  backgroundColor: Colors.white,
                  onPressed: _moveToCompanyLocation,
                  tooltip: 'Move to company location',
                  child: const Icon(Icons.business, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkIn(String type) async {
    final timeZoneIdentifier = await LocalePlus().getTimeZoneIdentifier();
    String? empId = singletonClass.getJWTModel()?.empId;
    String sn = empId?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String deviceIp = await _getLocalIpAddress();
    String? timeZoneName = timeZoneIdentifier;

    if (kDebugMode) {
      print(currentTime);
    }

    Map<String, dynamic> data = {
      "deviceUserId": "$empId",
      "sn": sn,
      "timestamp": currentTime,
      "status": 1,
      "verify_type": 0,
      "deviceIp": deviceIp,
      "deviceName": "remoteLocation",
      "captureTime": currentTime,
      "timeZone": timeZoneName
    };

    String body = json.encode(data);
    if (kDebugMode) {
      print("body of check in $body");
    }

    var uri = Uri.parse('${singletonClass.baseURL}/zk-teco/zktecoClient');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );

      if (kDebugMode) {
        print(response.body);
      }

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        await singletonClass.getClockingData();
        await _loadMapState();

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: AppLocalizations.of(context)!.success,
          text: isCheckedIn
              ? AppLocalizations.of(context)!.checkOut
              : AppLocalizations.of(context)!.checkInComplete,
          autoCloseDuration: const Duration(seconds: 3),
          showCancelBtn: false,
          showConfirmBtn: false,
        );

        setState(() {});
      } else if (response.statusCode == 400) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Validation failed. Please check your inputs.',
          autoCloseDuration: const Duration(seconds: 3),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'An unexpected error occurred. Please try again.',
          autoCloseDuration: const Duration(seconds: 3),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print('Error: $e');
      }

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred. Please check your network connection.',
        autoCloseDuration: const Duration(seconds: 3),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
    }
  }

  Future<String> _getLocalIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.isLoopback &&
            addr.address.startsWith('192.168')) {
          return addr.address;
        }
      }
    }
    return 'Unknown';
  }
}