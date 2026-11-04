import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../profile/data/models/user_profile_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final String? accessToken;
  final bool isOfflineFallback;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.isOfflineFallback = false,
  });
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'medivision_access_token';
  static const _refreshTokenKey = 'medivision_refresh_token';

  /// Authenticate user credentials against Node.js backend
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final tokenData = data['data']['tokens'] as Map<String, dynamic>;
        final user = data['data']['user'] as Map<String, dynamic>;

        await _storage.write(
          key: _tokenKey,
          value: tokenData['accessToken'] as String,
        );
        await _storage.write(
          key: _refreshTokenKey,
          value: tokenData['refreshToken'] as String,
        );

        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'Sign in successful',
          user: user,
          accessToken: tokenData['accessToken'] as String,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'Authentication failed',
        );
      }
    } catch (e) {
      debugPrint('Node backend connection exception: $e. Falling back to local clinical session.');
      // Offline fallback: Allows testing even if Node server hasn't been started yet
      return AuthResult(
        success: true,
        message: 'Signed in with local clinical session (Server offline)',
        user: {
          'fullName': 'Alex Morgan',
          'email': email,
          'gender': 'female',
          'role': 'patient',
        },
        isOfflineFallback: true,
      );
    }
  }

  /// Register a new account against Node.js backend
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName.trim(),
              'email': email.trim(),
              'password': password,
              'gender': gender ?? 'unspecified',
              'dateOfBirth': dateOfBirth,
            }),
          )
          .timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final tokenData = data['data']['tokens'] as Map<String, dynamic>;
        final user = data['data']['user'] as Map<String, dynamic>;

        await _storage.write(
          key: _tokenKey,
          value: tokenData['accessToken'] as String,
        );

        return AuthResult(
          success: true,
          message: data['message'] as String? ?? 'Account created successfully',
          user: user,
          accessToken: tokenData['accessToken'] as String,
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] as String? ?? 'Registration failed',
        );
      }
    } catch (e) {
      debugPrint('Node backend register exception: $e. Using local registration.');
      return AuthResult(
        success: true,
        message: 'Account registered locally (Server offline)',
        user: {
          'fullName': fullName,
          'email': email,
          'gender': gender ?? 'unspecified',
          'role': 'patient',
        },
        isOfflineFallback: true,
      );
    }
  }

  /// Update user profile in the persistent database
  static Future<bool> updateProfile(UserProfileModel profile) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return false;

      final response = await http
          .put(
            Uri.parse(ApiConstants.profile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to sync profile to backend: $e');
      return false;
    }
  }

  /// Fetch full user profile from the database
  static Future<UserProfileModel?> fetchProfile() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return null;

      final response = await http
          .get(
            Uri.parse(ApiConstants.profile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['data']['user'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch profile from backend: $e');
      return null;
    }
  }

  /// Sign out user and clear secure JWT tokens
  static Future<void> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        await http
            .post(
              Uri.parse(ApiConstants.logout),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 2));
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  /// Get current stored JWT token
  static Future<String?> getStoredToken() async {
    return _storage.read(key: _tokenKey);
  }
}

