class AppConstants {
  // API Endpoints
  static const String apiLogin = '/api/Account/login';
  static const String apiLogout = '/api/Account/logout';
  static const String apiProfile = '/api/Account/profile';
  static const String apiUpdateProfile = '/api/Account/profile';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 20.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

