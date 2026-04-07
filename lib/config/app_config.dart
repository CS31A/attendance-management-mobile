import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  static String get baseUrl =>
      dotenv.env['API_URL'] ??
      'https://ams-bpcac7gvb5cnhtdt.southeastasia-01.azurewebsites.net';

  // App Information
  static const String appName = 'Attendance Management';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyLoggedIn = 'app_logged_in';

  // Theme Colors
  static const int primaryColorValue = 0xFF3B82F6;
  static const int secondaryColorValue = 0xFF1E3A8A;
  static const int accentColorValue = 0xFF60A5FA;

  // Debug Helper
  static void logConfigStatus() {
    print('🚀 AppConfig Initialization:');
    print('   - Base URL: $baseUrl');
    print('   - App Name: $appName');
    print('   - Version: $appVersion');
  }
}
