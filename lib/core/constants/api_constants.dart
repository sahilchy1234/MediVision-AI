import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android emulator, localhost for Web / Windows / macOS / iOS
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get profile => '$baseUrl/user/profile';
  static String get permissions => '$baseUrl/user/permissions';
  static String get health => '$baseUrl/health';
}

