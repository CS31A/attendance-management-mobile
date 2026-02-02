import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  static String get baseUrl =>
      dotenv.env['API_URL'] ??
      'http://attendance.eba-8g72z7wh.ap-southeast-1.elasticbeanstalk.com';

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
}
