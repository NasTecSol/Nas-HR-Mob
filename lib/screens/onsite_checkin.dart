import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class OnsiteCheckin extends StatefulWidget {
  const OnsiteCheckin({super.key});

  @override
  State<OnsiteCheckin> createState() => _OnsiteCheckinState();
}

class _OnsiteCheckinState extends State<OnsiteCheckin> {
  late MapboxMap _mapboxMap;
  static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");
  // Initial map center position (example: Riyadh)
  final LatLng _initialPosition = LatLng(33.5985712, 73.1552995);
  final double _initialZoom = 14.0;

  @override
  void initState() {
    super.initState();
  }


  void _moveToLocation(double latitude, double longitude) {
    _mapboxMap.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(longitude, latitude),
        ),
        zoom: _initialZoom,
      ),
      MapAnimationOptions(
        duration: 1000,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ACCESS_TOKEN.isEmpty
          ? buildAccessTokenWarning()
          : MapWidget(
        textureView: true,
        androidHostingMode: AndroidPlatformViewHostingMode.HC,
        styleUri: MapboxStyles.SATELLITE_STREETS,
        onMapCreated: (controller) {
          setState(() {
            _mapboxMap = controller;
          });
        },
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              _initialPosition.longitude,
              _initialPosition.latitude,
            ),
          ),
          zoom: _initialZoom,
        ),
      ),
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Please pass in your access token with",
            "--dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE",
            "passed into flutter run or add it to args in vscode's launch.json",
          ]
              .map((text) => Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
