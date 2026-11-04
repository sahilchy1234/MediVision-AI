import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base URL configuration for the backend.
  /// 
  /// Options for running with the backend:
  /// 1. ADB Reverse Port Forwarding (Default - recommended for physical Android USB & Emulators):
  ///    Run `adb reverse tcp:5000 tcp:5000` (or run `start_port_forward.bat`).
  ///    This allows your phone to access http://127.0.0.1:5000/api seamlessly.
  /// 
  /// 2. Without ADB Reverse on Android Emulator:
  ///    Set [usePortForwarding] = false to fallback to http://10.0.2.2:5000/api.
  /// 
  /// 3. Over Wi-Fi (Physical Phone on same Wi-Fi as PC):
  ///    Set [customBaseUrl] = 'http://`YOUR_PC_IP`:5000/api'.
  static bool usePortForwarding = true;

  /// Optional custom override (e.g., 'http://192.168.1.15:5000/api' or ngrok URL)
  static String? customBaseUrl = 'https://satchel-thirsting-trough.ngrok-free.dev/api';

  static String get baseUrl {
    // When running in a web browser on desktop, connect directly to localhost backend
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }

    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return customBaseUrl!.trim();
    }

    // ADB reverse port forwarding routes 127.0.0.1:5000 on the device to port 5000 on the host PC
    if (usePortForwarding) {
      return 'http://127.0.0.1:5000/api';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  /// Standard headers including authorization and ngrok browser warning bypass
  static Map<String, String> headers([String? token]) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get profile => '$baseUrl/user/profile';
  static String get permissions => '$baseUrl/user/permissions';
  static String get health => '$baseUrl/health';
  static String get aiChat => '$baseUrl/ai/chat';
  static String get aiStatus => '$baseUrl/ai/status';
  static String get aiPhysiologicalSystems => '$baseUrl/ai/physiological-systems';
  static String get records => '$baseUrl/records';
  static String get timeline => '$baseUrl/timeline';
  static String timelineItem(String id) => '$baseUrl/timeline/$id';
  static String get vitals => '$baseUrl/vitals';
  static String get vitalsActivity => '$baseUrl/vitals/activity';
  static String get vitalsHistory => '$baseUrl/vitals/history';
  static String record(String id) => '$baseUrl/records/$id';
  static String analyzeRecord(String id) => '$baseUrl/records/$id/analyze';

  // Women's Health Endpoints
  static String get womensHealth => '$baseUrl/womens-health';
  static String get womensHealthCycle => '$baseUrl/womens-health/cycle';
  static String get womensHealthSymptoms => '$baseUrl/womens-health/symptoms';
  static String get womensHealthScreeningsAnalyze => '$baseUrl/womens-health/screenings/analyze';
  static String get womensHealthVaultToggle => '$baseUrl/womens-health/vault/toggle';
}
