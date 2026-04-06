class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Map<String, dynamic>) {
      return error['message']?.toString() ?? 'An error occurred';
    } else {
      return error.toString();
    }
  }

  static String getApiErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey('message')) {
      return response['message'].toString();
    }
    
    if (response.containsKey('errors')) {
      final errors = response['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }
    
    return 'An unexpected error occurred';
  }

  static Map<String, List<String>>? getFieldErrors(Map<String, dynamic> response) {
    if (!response.containsKey('errors')) {
      return null;
    }

    final errors = response['errors'] as Map<String, dynamic>?;
    if (errors == null) return null;

    final fieldErrors = <String, List<String>>{};
    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      }
    });

    return fieldErrors.isEmpty ? null : fieldErrors;
  }
}

