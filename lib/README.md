# Project Structure

This directory contains the source code for the Attendance Management Mobile application.

## Directory Structure

```
lib/
├── config/          # Application configuration files
│   ├── app_config.dart      # App-wide configuration constants
│   └── app_routes.dart      # Route definitions and navigation
├── models/          # Data models
│   ├── admin.dart
│   ├── student.dart
│   ├── teacher.dart
│   └── user.dart
├── providers/       # State management providers
│   └── app_data.dart        # App-wide state management
├── screens/         # UI screens
│   ├── admin_dashboard.dart
│   ├── classes_screen.dart
│   ├── profile_screen.dart
│   └── ...
├── services/        # API and business logic services
│   ├── api_service.dart     # API communication
│   └── storage_service.dart  # Local storage management
├── theme/           # Theme and styling
│   └── app_theme.dart       # Colors, themes, and styling utilities
├── utils/           # Utility functions and helpers
│   ├── constants.dart       # App-wide constants
│   ├── validators.dart      # Form validation helpers
│   ├── extensions.dart      # Dart extensions (BuildContext, String, DateTime)
│   ├── error_handler.dart   # Error handling utilities
│   └── dialog_helper.dart   # Dialog/modal helper functions
├── widgets/         # Reusable UI components
│   ├── custom_button.dart       # Custom button widget
│   ├── custom_text_field.dart   # Custom text field widget
│   ├── loading_widget.dart      # Loading indicator widget
│   ├── error_widget.dart        # Error display widget
│   └── empty_state_widget.dart  # Empty state widget
└── main.dart        # Application entry point
```

## Description

### **config/**
- `app_config.dart`: Application-wide configuration constants (API URLs, app info, storage keys)
- `app_routes.dart`: Centralized route definitions and navigation configuration

### **models/**
- Data models representing entities in the application (Admin, Student, Teacher, User)

### **providers/**
- State management classes using ValueNotifier and similar patterns
- `app_data.dart`: Manages app-wide state (teachers, students, users)

### **screens/**
- All screen/widget files for different pages of the app
- Organized by feature/functionality

### **services/**
- `api_service.dart`: Handles all API communication
- `storage_service.dart`: Manages local storage (tokens, preferences)

### **theme/**
- `app_theme.dart`: Theme definitions, colors, gradients, and styling utilities

### **utils/**
- `constants.dart`: App-wide constants (endpoints, validation rules, UI constants)
- `validators.dart`: Form validation helper functions
- `extensions.dart`: Useful extensions for BuildContext, String, DateTime
- `error_handler.dart`: Centralized error handling and parsing
- `dialog_helper.dart`: Helper functions for showing dialogs and modals

### **widgets/**
- Reusable custom widgets used across the application
- `custom_button.dart`: Standardized button component
- `custom_text_field.dart`: Standardized text field component
- `loading_widget.dart`: Loading indicator component
- `error_widget.dart`: Error display component
- `empty_state_widget.dart`: Empty state display component

## Best Practices

1. **Use Extensions**: Import `utils/extensions.dart` to use helpful extensions like `context.showSnackBar()`
2. **Error Handling**: Use `ErrorHandler` class for consistent error message extraction
3. **Dialogs**: Use `DialogHelper` for showing confirmation and success dialogs
4. **Widgets**: Use reusable widgets from `widgets/` folder for consistent UI
5. **Theme**: Use `AppTheme` for colors and styling instead of hardcoding values
6. **Validation**: Use `Validators` class for form validation

