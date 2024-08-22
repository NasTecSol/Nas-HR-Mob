import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Method to check if biometric authentication is available
  Future<bool> checkBiometricAvailability() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isBiometricSupported = await _localAuth.isDeviceSupported();
    return canCheckBiometrics && isBiometricSupported;
  }

  // Method to authenticate with biometrics
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    bool isAuthenticated = false;
    try {
      if (!(await checkBiometricAvailability())) {
        // Show a message asking the user to set up biometric credentials
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set up biometrics in your device settings')),
        );
        return false; // Skip the authentication attempt if biometrics aren't set up
      }

      // Proceed with authentication
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e);
    }
    return isAuthenticated;
  }
}
