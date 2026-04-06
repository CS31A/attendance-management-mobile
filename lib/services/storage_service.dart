import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyInstructorId = 'instructor_id';

  // Save tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // Save instructor ID
  static Future<void> saveInstructorId(String instructorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInstructorId, instructorId);
  }

  // Get instructor ID
  static Future<String?> getInstructorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInstructorId);
  }

  // Clear all tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyInstructorId);
  }
}

