import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double? _companyLatitude;
  double? _companyLongitude;

  @override
  void initState() {
    super.initState();
    _parseCompanyLocation();
    _getCurrentLocation();
    _loadMapState();
  }

  // Parse the company location from the model and set the company lat and long
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


  // Load the check-in state from shared preferences
  Future<void> _loadMapState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCheckedIn = prefs.getBool('isCheckInCompleted') ?? false;
    });
  }

  // Save the check-in state to shared preferences
  Future<void> _saveCheckInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckInCompleted', isCheckedIn);
  }

  // Get current location and update the map with current location and check proximity
  Future<void> _getCurrentLocation() async {
    PermissionStatus permissionGranted = await _location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      _currentLocation = await _location.getLocation();
      _moveToLocation(_currentLocation!.latitude!, _currentLocation!.longitude!);
      _addCurrentLocationMarker(_currentLocation!);
      _addCompanyLocationMarker(); // Add company location marker
      _checkProximityToCompanyLocation(); // Check if the user is in range
    }
  }

  // Move the map view to the given coordinates
  void _moveToLocation(double latitude, double longitude) {
    _mapboxMap.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 18.0,
      ),
      MapAnimationOptions(
        duration: 1000,
      ),
    );
  }

  // Add a marker at the current location
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

  // Check if the user is within the proximity of the company location
  void _checkProximityToCompanyLocation() {
    if (_currentLocation != null) {
      final double distance = _calculateDistance(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        _companyLatitude!,
        _companyLongitude!,
      );

      if (distance > _radiusInMeters) {
        _showOutOfLocationMessage();
      } else {
        _showCheckInConfirmationDialog(); // Show check-in confirmation if within radius
      }
    }
  }

  // Calculate the distance between two coordinates (in meters)
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

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  // Show an alert if the user is out of the company location's radius
  void _showOutOfLocationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.sorryYouAreOutOfTheLocationRadius)),
    );
  }

  // Show a dialog asking if the user is sure about checking in
  void _showCheckInConfirmationDialog() {
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
                  if(singletonClass.remoteAttendanceModelList.first.data!.first.isRemoteAttendance == true) {
                    checkIn("biometric");
                  }
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

  // Add a company location marker and draw the radius boundary
  void _addCompanyLocationMarker() async {
    final ByteData bytes = await rootBundle.load('images/site.png');
    final Uint8List list = bytes.buffer.asUint8List();

    // Create a point annotation for the company location
    await _mapboxMap.annotations.createPointAnnotationManager().then((pointAnnotationManager) {
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude!, _companyLatitude!)),
        image: list,
        iconSize: 0.5,
      );
      pointAnnotationManager.create(pointAnnotationOptions);
    });

    // Draw a circle to represent the company's location radius
    await _mapboxMap.annotations.createCircleAnnotationManager().then((circleAnnotationManager) {
      final circleAnnotationOptions = CircleAnnotationOptions(
        geometry: Point(coordinates: Position(_companyLongitude!, _companyLatitude!)),
        circleRadius: _radiusInMeters / 100,
        circleColor: 0x0000FF,
        circleOpacity: 0.3,
        circleStrokeColor: 0x0000FF,
        circleStrokeWidth: 1.0,
      );
      circleAnnotationManager.create(circleAnnotationOptions);
    });
  }

  // Move the map view to the company's location
  Future<void> _moveToCompanyLocation() async {
    _moveToLocation(_companyLatitude!, _companyLongitude!);
  }

  // Move the map view to the current location
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
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'unique_tag_for_fab_1',
                  backgroundColor: Colors.white,
                  onPressed: _moveToCurrentLocation,
                  tooltip: 'Move to current location',
                  child: const Icon(Icons.location_on, color: Colors.blue),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  heroTag: 'unique_tag_for_fab_2',
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
  String currentTime = DateTime.now().toUtc().toIso8601String();
  String checkInTime = '${currentTime.split('.')[0]}.000Z';
  print(checkInTime);

    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkInTime": checkInTime,
      "type": type,
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

