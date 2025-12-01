import 'package:flutter/services.dart';

class Environment {
  static const MethodChannel _channel = MethodChannel('env_channel');

  static Future<String> detectEnv() async {
    try {
      final bool isTestFlight = await _channel.invokeMethod('isTestFlight') ?? false;
      if (isTestFlight) {
        print("🔥 Running TestFlight build");
      }
      return isTestFlight ? "staging" : "production";
    } catch (_) {
      return "production";
    }
  }
}
