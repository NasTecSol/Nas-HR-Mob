import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../request_controller/check_in_model.dart';

class OnsiteCheckin extends StatefulWidget {
  const OnsiteCheckin({super.key});

  @override
  State<OnsiteCheckin> createState() => _OnsiteCheckinState();
}

class _OnsiteCheckinState extends State<OnsiteCheckin> {
  SingletonClass singletonClass = SingletonClass();
  bool isCheckedIn = false;
  bool isLoading = false;
  late MapboxMap _mapboxMap;
  LocationData? _currentLocation;
  final Location _location = Location();

  // Company location (example coordinates)
  final double _radiusInMeters = 100.0;
  late final double _companyLatitude;
  late final double _companyLongitude;

  @override
  void initState() {
    super.initState();
    _parseCompanyLocation();
    _getCurrentLocation();
    _loadMapState();
  }

  void _parseCompanyLocation() {
    final String? locString = singletonClass.remoteAttendanceModelList.isNotEmpty && singletonClass.remoteAttendanceModelList.first.data!.remoteAttendanceLoc!.isNotEmpty
        ? SingletonClass().remoteAttendanceModelList.first.data?.remoteAttendanceLoc
        : null;
    if (locString != null && locString.contains(',')) {
      final parts = locString.split(',');
      if (parts.length == 2) {
        _companyLatitude = double.tryParse(parts[0].trim()) ?? 0.0;
        _companyLongitude = double.tryParse(parts[1].trim()) ?? 0.0;
      }
    }
  }



  Future<void> _loadMapState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCheckedIn = prefs.getBool('isCheckInCompleted') ?? false;
    });
  }

  Future<void> _saveCheckInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckInCompleted', isCheckedIn);
  }


  Future<void> _getCurrentLocation() async {
    // Check and request permissions
    PermissionStatus permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      _currentLocation = await _location.getLocation();
      _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
      _addCurrentLocationMarker(_currentLocation!);
      _addCompanyLocationMarker(); // Add company location marker with boundary
      _checkProximityToCompanyLocation(); // Check distance from company location
    }
  }

  void _moveToLocation(double latitude, double longitude) {
    _mapboxMap.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(longitude, latitude),
        ),
        zoom: 18.0, // Zoom level for street view
      ),
      MapAnimationOptions(
        duration: 1000,
      ),
    );
  }

  void _addCurrentLocationMarker(LocationData locationData) async {
    final ByteData bytes = await rootBundle.load('images/placeholder.png');
    final Uint8List list = bytes.buffer.asUint8List();

    // Create a point annotation at the current location
    await _mapboxMap.annotations.createPointAnnotationManager().then((pointAnnotationManager) {
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(locationData.longitude!, locationData.latitude!)),
        image: list,
        iconSize: 0.2,
      );
      pointAnnotationManager.create(pointAnnotationOptions);
    });
  }

  void _checkProximityToCompanyLocation() {
    if (_currentLocation != null) {
      final double distance = _calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        _companyLatitude,
        _companyLongitude,
      );

      if (distance > _radiusInMeters) {
        _showOutOfLocationMessage();
      } else {
        _showAlertDialog(); // Show the dialog if within the location radius
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of the Earth in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  void _showOutOfLocationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(AppLocalizations.of(context)!.sorryYouAreOutOfTheLocationRadius)),
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCheckedIn ? AppLocalizations.of(context)!.checkOut : AppLocalizations.of(context)!.checkIn),
          content: Text(
            isCheckedIn
                ? AppLocalizations.of(context)!.areYouSure
                : AppLocalizations.of(context)!.youHaveNotCheckedInYet,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:  Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (isCheckedIn) {
                  checkOut();
                } else {
                  checkIn("biometric");
                }
                Navigator.pop(context);
              },
              child: Text(isCheckedIn ?  AppLocalizations.of(context)!.checkOut : AppLocalizations.of(context)!.checkIn),
            ),
          ],
        );
      },
    );
  }


  void _addCompanyLocationMarker() async {
    final ByteData bytes = await rootBundle.load('images/site.png'); // Use your company icon
    final Uint8List list = bytes.buffer.asUint8List();

    // Create a point annotation for the company location
    await _mapboxMap.annotations.createPointAnnotationManager().then((pointAnnotationManager) {
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude, _companyLatitude)),
        image: list,
        iconSize: 0.5, // Adjust the icon size as needed
      );
      pointAnnotationManager.create(pointAnnotationOptions);
    });

    // Draw a circle to represent the company's location radius
    await _mapboxMap.annotations.createCircleAnnotationManager().then((circleAnnotationManager) {
      final circleAnnotationOptions = CircleAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude, _companyLatitude)),
        circleRadius: _radiusInMeters / 100,
        circleColor: 0x0000FF,
        circleOpacity: 0.3,
        circleStrokeColor: 0x0000FF,
        circleStrokeWidth: 1.0,
      );
      circleAnnotationManager.create(circleAnnotationOptions);
    });
  }

  Future<void> _moveToCompanyLocation() async {
    _moveToLocation(_companyLatitude, _companyLongitude);
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.currentLocationNotAvailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            androidHostingMode: AndroidPlatformViewHostingMode.HC,
            styleUri: MapboxStyles.STANDARD,
            onMapCreated: (controller) {
              setState(() {
                _mapboxMap = controller;
              });
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'unique_tag_for_fab_1',
                  backgroundColor: Colors.white,
                  onPressed: _moveToCurrentLocation,
                  tooltip: 'Move to Current Location',
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8.0),
                FloatingActionButton(
                  heroTag: 'unique_tag_for_fab_2',
                  backgroundColor: Colors.white,
                  onPressed: _moveToCompanyLocation,
                  tooltip: 'Move to Company Location',
                  child: const Icon(Icons.location_city),
                ),
              ],
            ),
          ),
          if(isLoading)
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('images/loader.json'),
              ),
            )
        ],
      ),
    );
  }

  Future<void> checkIn(String type) async {
    String checkInTime = DateTime.now().toIso8601String();
    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkInTime": checkInTime,
      "type": type,
      "totalTime" : checkInTime,
      // Adjust this if needed for total time calculation
    };
    print(data);

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/create');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      setState(() {
        isLoading = false;
      });
      print(response.body);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        var checkInData = CheckInData.fromJson(decodedResponse);
        singletonClass.setCheckInData([checkInData]);
        print(singletonClass.checkInDataList.first.data?.id);
        setState(() {
          isCheckedIn = true;
        });
        await _saveCheckInState();
        await Future.delayed(const Duration(seconds: 2));
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title:  AppLocalizations.of(context)!.success,
          text: AppLocalizations.of(context)!.checkInComplete,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else if (response.statusCode == 400) {
        // Show error alert for status code 400
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Validation failed. Please check your inputs.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else {
        // Handle other error statuses
        print('Error: ${response.statusCode}');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'An unexpected error occurred. Please try again.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');

      // Show error alert for exceptions
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred. Please check your network connection.',
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
    }
  }

//CHECK OUT API CALL
  Future<void> checkOut() async {
    String checkOutTime = DateTime.now().toIso8601String();

    // Fetch the check-in time from the singleton class
    String? checkInTime = singletonClass.checkInDataList.first.data?.checkInTime;

    // Calculate the duration between check-in and check-out
    if (checkInTime != null) {
      DateTime checkInDateTime = DateTime.parse(checkInTime);
      DateTime checkOutDateTime = DateTime.parse(checkOutTime);
      Duration difference = checkOutDateTime.difference(checkInDateTime);
      String totalHours = "${difference.inHours}h ${difference.inMinutes.remainder(60)}m";
      print("Total time spent: $totalHours");

      // Fetch the check-in ID for updating the record
      String? id = singletonClass.checkInDataList.first.data?.id;

      // Prepare data for the check-out API call
      Map<String, dynamic> data = {
        "employeeId": singletonClass.getJWTModel()?.employeeId,
        "employeeName": singletonClass.getJWTModel()?.userName,
        "checkOutTime": checkOutTime,
        "type": singletonClass.checkInDataList.first.data?.type,
        "totalTime": totalHours,
      };
      print("Check-out data: $data");

      String body = json.encode(data);
      var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/$id');
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.patch(
          uri,
          body: body,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json",
          },
        );

        setState(() {
          isLoading = false;
        });
        print("Check-out response: ${response.body}");

        if (response.statusCode == 200) {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            isCheckedIn = false;
          });
          await _saveCheckInState();
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: AppLocalizations.of(context)!.success,
            text: AppLocalizations.of(context)!.checkOutComplete,
            autoCloseDuration: const Duration(seconds: 5),
            showCancelBtn: false,
            showConfirmBtn: false,
          );
        } else if (response.statusCode == 400) {
          // Handle validation error
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'Validation failed. Please check your inputs.',
            autoCloseDuration: const Duration(seconds: 5),
            showCancelBtn: false,
            showConfirmBtn: false,
          );
        } else {
          // Handle other server errors
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'An unexpected error occurred. Please try again.',
            autoCloseDuration: const Duration(seconds: 5),
            showCancelBtn: false,
            showConfirmBtn: false,
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Check-out Error: $e');

        // Handle network errors or exceptions
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'An error occurred. Please check your network connection.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      }
    } else {
      // Handle the case where the check-in time is null
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'No Check-In Found',
        text: 'You must check in before checking out.',
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
    }
  }
}

