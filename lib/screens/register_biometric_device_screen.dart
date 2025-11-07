import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';

import '../widgets/loader.dart';

class RegisterBiometricDeviceScreen extends StatefulWidget {
  final String empId;
  final String firstName;
  final String lastName;
  final String userName;

  const RegisterBiometricDeviceScreen({
    super.key,
    required this.empId,
    required this.firstName,
    required this.lastName,
    required this.userName,
  });

  @override
  State<RegisterBiometricDeviceScreen> createState() =>
      _RegisterBiometricDeviceScreenState();
}

class _RegisterBiometricDeviceScreenState
    extends State<RegisterBiometricDeviceScreen> {
  final SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  String? selectedDeviceName;
  String? selectedDeviceId;

  @override
  void initState() {
    super.initState();
    singletonClass.getBiometricDevices();
  }

  @override
  Widget build(BuildContext context) {
    final empID = widget.empId;
    final name = "${widget.firstName} ${widget.lastName}".trim();

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Header Row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(index: 0),
                          ),
                        ),
                        icon: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 3,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.registerBiometrics,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (selectedDeviceId != null &&
                              selectedDeviceName != null) {
                            enqueueUser(selectedDeviceId!, selectedDeviceName!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .pleaseSelectDevice),
                              ),
                            );
                          }
                        },
                        icon: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 3,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.done, color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Employee Registration Info
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.employeeIsRegistered,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// 🔹 Animation
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('images/done.json'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// 🔹 Employee Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.name}: ",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.employee}${AppLocalizations.of(context)!.id}: ",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        empID,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🔹 Instructions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "${AppLocalizations.of(context)!.toEnrollThisEmployeeOnBiometricDevice}, ${AppLocalizations.of(context)!.selectBiometricDevice}",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Device Dropdown
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    value: selectedDeviceName,
                    hint: Text(AppLocalizations.of(context)!.selectDevice),
                    items: singletonClass
                        .biometricDevicesModelDataList.first.data!
                        .map<DropdownMenuItem<String>>(
                          (device) {
                        return DropdownMenuItem<String>(
                          value: device.deviceName,
                          child: Text(device.deviceName ?? ''),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeviceName = value;
                        final selectedDevice = singletonClass
                            .biometricDevicesModelDataList.first.data!
                            .firstWhere(
                              (d) => d.deviceName == value,
                        );
                        selectedDeviceId = selectedDevice.deviceId ?? '';
                      });
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          /// 🔹 Bottom "Skip" Button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen(index: 0)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          /// 🔹 Loader Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Loader(),
            ),
        ],
      ),
    );
  }

  /// 🔹 API Call to Enqueue User
  Future<void> enqueueUser(String deviceId, String deviceName) async {
    final pin = widget.empId;
    final name = "${widget.firstName} ${widget.lastName}".trim();
    final cardNo = "0";
    final uri = Uri.parse("${singletonClass.baseURL}/iclock/enqueue-user");

    final Map<String, dynamic> data = {
      "sn": deviceId,
      "pin": pin,
      "name": name,
      "privilege": 0,
      "cardno": cardNo,
    };

    try {
      setState(() => isLoading = true);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:Text(
                "✅${AppLocalizations.of(context)!.registerBiometrics} ${AppLocalizations.of(context)!.success}: $deviceName"),
          ),
        );
        setState(() => isLoading = false);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MainScreen(index: 0)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Error registering device")),
      );
      setState(() => isLoading = false);
    }
  }
}
