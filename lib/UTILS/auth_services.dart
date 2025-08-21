import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:nashr/l10n/app_localizations.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Method to check if biometric authentication is available
  Future<bool> checkBiometricAvailability() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    bool isBiometricSupported = await _localAuth.isDeviceSupported();
    return canCheckBiometrics && isBiometricSupported;
  }

  /// Method to authenticate with biometrics
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    bool isAuthenticated = false;
    try {
      if (!(await checkBiometricAvailability())) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSetupBiometric)),
          );
        });
        return false;
      }
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context)!.pleaseAuthenticate,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return isAuthenticated;
  }
}
