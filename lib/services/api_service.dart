import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  // Update this to your actual backend URL
  static const String baseUrl = 'https://localhost:8081';
  
  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/account/login');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };
      
      final body = {
        'username': username,
        'password': password,
      };

      print('📤 Logging in: $url');
      print('📦 Request body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'],
          'accessToken': responseData['accessToken'],
          'refreshToken': responseData['refreshToken'],
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'accessToken': null,
          'refreshToken': null,
          'user': null,
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server. Please check your internet connection.',
        'accessToken': null,
        'refreshToken': null,
        'user': null,
      };
    }
  }

  // Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String username,
    String? firstname,
    String? lastname,
    required String email,
    required String password,
    required String repeatedPassword,
    String? role,
    String? sectionId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/account/register');
      final headers = await _getHeaders();
      
      final body = {
        'username': username,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'repeatedPassword': repeatedPassword,
        'role': role,
        'sectionId': sectionId,
      };

      print('📤 Registering user: $url');
      print('📦 Request body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'User registered successfully',
        };
      } else {
        // Handle error response
        String errorMessage = 'Registration failed';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            }
          });
          errorMessage = errorList.join(', ');
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'] as String;
        } else if (responseData.containsKey('title')) {
          errorMessage = responseData['title'] as String;
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Register user error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server. Please check your internet connection.',
      };
    }
  }

  // Get list of users
  Future<Map<String, dynamic>> getUsers() async {
    try {
      // Try admin users endpoint first
      final url = Uri.parse('$baseUrl/api/account/admin/users');
      final headers = await _getHeaders();

      print('📤 Fetching users: $url');

      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle different response structures
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            return {
              'success': true,
              'data': responseData['data'],
            };
          } else if (responseData.containsKey('users')) {
            return {
              'success': true,
              'data': responseData['users'],
            };
          } else {
            return {
              'success': true,
              'data': responseData,
            };
          }
        } else if (responseData is List) {
          return {
            'success': true,
            'data': responseData,
          };
        } else {
          return {
            'success': true,
            'data': [],
          };
        }
      } else if (response.statusCode == 404) {
        // If endpoint doesn't exist, return empty list for now
        print('⚠️ Users endpoint not found, returning empty list');
        return {
          'success': true,
          'data': [],
          'message': 'Users endpoint not available',
        };
      } else {
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch users',
        };
      }
    } catch (e) {
      print('❌ Get users error: $e');
      
      // If it's a format exception, try to return empty list
      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        return {
          'success': true,
          'data': [],
          'message': 'Users endpoint not available',
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? username,
    String? firstname,
    String? lastname,
    String? email,
    String? role,
    String? sectionId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/account/admin/users/$userId');
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (firstname != null) body['firstname'] = firstname;
      if (lastname != null) body['lastname'] = lastname;
      if (email != null) body['email'] = email;
      if (role != null) body['role'] = role;
      if (sectionId != null) body['sectionId'] = sectionId;

      print('📤 Updating user: $url');
      print('📦 Request body: $body');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User updated successfully',
        };
      } else {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      print('❌ Update user error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/account/admin/users/$userId');
      final headers = await _getHeaders();

      print('📤 Deleting user: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'User deleted successfully',
        };
      } else {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      print('❌ Delete user error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }
}

