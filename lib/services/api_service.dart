import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  // Use AppConfig for the base URL to ensure consistency
  static String get baseUrl => AppConfig.baseUrl;

  // Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders({bool skipAuth = false}) async {
    if (skipAuth) {
      return {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };
    }
    final token = await StorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Make an authenticated request with automatic token refresh on 401
  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFn, {
    bool isRefreshRequest = false,
  }) async {
    // Make the initial request
    var response = await requestFn();

    // If we get a 401 and this is not a refresh request, try to refresh the token
    if (response.statusCode == 401 && !isRefreshRequest) {
      print('🔑 Received 401, attempting to refresh token...');

      // Prevent multiple simultaneous refresh attempts
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshResult = await refreshToken();

          if (refreshResult['success'] == true) {
            print(
                '✅ Token refreshed successfully, retrying original request...');
            // Retry the original request with the new token
            response = await requestFn();
          } else {
            print('❌ Token refresh failed: ${refreshResult['message']}');
            // If refresh fails, clear tokens and return the 401 response
            await StorageService.clearTokens();
          }
        } catch (e) {
          print('❌ Token refresh error: $e');
          await StorageService.clearTokens();
        } finally {
          _isRefreshing = false;
        }
      } else {
        // If refresh is already in progress, wait a bit and retry
        await Future.delayed(const Duration(milliseconds: 500));
        response = await requestFn();
      }
    }

    return response;
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
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Login request timeout after 30 seconds');
          throw TimeoutException('Login request timeout');
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response headers: ${response.headers}');
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
          'message': responseData['message']?.toString(),
          'accessToken': responseData['accessToken']?.toString(),
          'refreshToken': responseData['refreshToken']?.toString(),
          'role': responseData['role']?.toString(),
          'user': responseData['user'],
        };
      } else {
        // Handle error response - extract message from various possible locations
        String errorMessage = 'Login failed';
        if (responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        } else if (responseData['details'] != null) {
          errorMessage = responseData['details'].toString();
        } else if (responseData['error'] != null) {
          errorMessage = responseData['error'].toString();
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'accessToken': null,
          'refreshToken': null,
          'role': null,
          'user': null,
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      String errorMessage = 'Failed to connect to server. Please check your internet connection.';
      
      if (e is TimeoutException) {
        errorMessage = 'Connection timeout. Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage = 'SSL certificate error. Please try again later.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'accessToken': null,
        'refreshToken': null,
        'user': null,
      };
    }
  }

  // Refresh access token (does NOT use _makeAuthenticatedRequest to avoid loops)
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshTokenValue = await StorageService.getRefreshToken();
      final oldAccessToken = await StorageService.getAccessToken();

      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        return {
          'success': false,
          'message': 'No refresh token available',
        };
      }

      final url = Uri.parse('$baseUrl/api/account/refresh');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        if (oldAccessToken != null) 'Authorization': 'Bearer $oldAccessToken',
      };

      final body = {
        'refreshToken': refreshTokenValue,
        'oldAccessToken': oldAccessToken,
      };

      print('📤 Refreshing token: $url');
      print(
          '📦 Request body: ${body.map((k, v) => MapEntry(k, k == 'refreshToken' || k == 'oldAccessToken' ? (v != null ? '${v.toString().substring(0, v.toString().length > 20 ? 20 : v.toString().length)}...' : null) : v))}');

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
        // Save new tokens if refresh was successful
        if (responseData['success'] == true &&
            responseData['accessToken'] != null) {
          await StorageService.saveTokens(
            responseData['accessToken'] as String,
            responseData['refreshToken'] as String? ?? refreshTokenValue,
          );
          print('✅ New tokens saved successfully');
        }

        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Token refreshed successfully',
          'accessToken': responseData['accessToken'],
          'refreshToken': responseData['refreshToken'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to refresh token',
          'accessToken': null,
          'refreshToken': null,
        };
      }
    } catch (e) {
      print('❌ Refresh token error: $e');
      return {
        'success': false,
        'message':
            'Failed to connect to server. Please check your internet connection.',
        'accessToken': null,
        'refreshToken': null,
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
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final errorMessages = value.map((e) => e.toString()).toList();
              fieldErrors![key] = errorMessages;
              errorList.addAll(errorMessages);
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
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Register user error: $e');
      return {
        'success': false,
        'message':
            'Failed to connect to server. Please check your internet connection.',
      };
    }
  }

  // Get list of users from /api/users endpoint
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final url = Uri.parse('$baseUrl/api/users');

      print('📤 Fetching users from /api/users: $url');

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.get(url, headers: headers);
      });

      print('📥 Users response status: ${response.statusCode}');
      print('📥 Users response body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);
        List<Map<String, dynamic>> users = [];

        // Handle different response formats
        if (responseData is List) {
          users = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          users = List<Map<String, dynamic>>.from(responseData['data']);
        } else if (responseData is Map<String, dynamic>) {
          print('⚠️ Unexpected users response format: $responseData');
        }

        // Normalize user data format
        final normalizedUsers = users.map((user) {
          final normalized = Map<String, dynamic>.from(user);

          // Map userId to id if needed
          if (normalized.containsKey('userId') &&
              !normalized.containsKey('id')) {
            normalized['id'] = normalized['userId'];
          }

          // Ensure role is properly formatted
          if (normalized.containsKey('role')) {
            final role = normalized['role']?.toString() ?? '';
            // Capitalize first letter
            if (role.isNotEmpty) {
              var formattedRole =
                  role[0].toUpperCase() + role.substring(1).toLowerCase();
              
              // Normalize backend alias Instructor to Teacher
              if (formattedRole == 'Instructor') {
                formattedRole = 'Teacher';
              }
              
              normalized['role'] = formattedRole;
            }
          }

          // Combine firstname and lastname into name field if needed
          if (normalized.containsKey('firstname') ||
              normalized.containsKey('lastname')) {
            final firstname = normalized['firstname']?.toString() ?? '';
            final lastname = normalized['lastname']?.toString() ?? '';
            normalized['firstname'] = firstname;
            normalized['lastname'] = lastname;
            normalized['name'] = '$firstname $lastname'.trim();
          }

          return normalized;
        }).toList();

        print('✅ Fetched ${normalizedUsers.length} users from /api/users');

        return {
          'success': true,
          'data': normalizedUsers,
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};

        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch users',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get users error: $e');

      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get current authenticated account details
  Future<Map<String, dynamic>> getCurrentAccount() async {
    try {
      final url = Uri.parse('$baseUrl/api/account/me');

      print('📤 Fetching current account: $url');
      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.get(url, headers: headers);
      });
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch account',
          'data': null,
        };
      }
    } catch (e) {
      print('❌ Get current account error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': null,
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

      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (firstname != null) body['firstname'] = firstname;
      if (lastname != null) body['lastname'] = lastname;
      if (email != null) body['email'] = email;
      if (role != null) body['role'] = role;
      if (sectionId != null) body['sectionId'] = sectionId;

      print('📤 Updating user: $url');
      print('📦 Request body: $body');

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.put(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      });

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

  // Update current authenticated user's profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstname,
    String? lastname,
    String? email,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    String? sectionId,
    bool? isRegular,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/account/profile');

      final body = <String, dynamic>{
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (email != null) 'email': email,
        if (currentPassword != null) 'currentPassword': currentPassword,
        if (newPassword != null) 'newPassword': newPassword,
        if (confirmNewPassword != null)
          'confirmNewPassword': confirmNewPassword,
        if (sectionId != null) 'sectionId': sectionId,
        if (isRegular != null) 'isRegular': isRegular,
      };

      print('📤 Updating profile: $url');
      print(
          '📦 Request body: ${Map<String, dynamic>.from(body)..updateAll((k, v) => k.toLowerCase().contains('password') ? '***' : v)}');

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.patch(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      });

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
          'message': responseData['message'] ?? 'Profile updated successfully',
          'updatedProfile': responseData['updatedProfile'],
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update profile';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final url = Uri.parse('$baseUrl/api/account/logout');

      print('📤 Logging out: $url');

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.post(
          url,
          headers: headers,
        );
      });

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
          'message': responseData['message'] ?? 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to logout',
        };
      }
    } catch (e) {
      print('❌ Logout error: $e');
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

      print('📤 Deleting user: $url');

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.delete(url, headers: headers);
      });

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

  // Get all classrooms
  Future<Map<String, dynamic>> getClassrooms() async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms');

      print('📤 Fetching classrooms: $url');
      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _getHeaders();
        return await http.get(url, headers: headers);
      });
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> classrooms = [];
        if (responseData is List) {
          classrooms = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          classrooms = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': classrooms,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch classrooms',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get classrooms error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get classroom by ID
  Future<Map<String, dynamic>> getClassroomById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms/$id');
      final headers = await _getHeaders();

      print('📤 Fetching classroom: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch classroom',
        };
      }
    } catch (e) {
      print('❌ Get classroom error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Create classroom
  Future<Map<String, dynamic>> createClassroom(String name) async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms');
      final headers = await _getHeaders();

      final body = {
        'name': name,
      };

      print('📤 Creating classroom: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Classroom created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to create classroom';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Create classroom error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update classroom
  Future<Map<String, dynamic>> updateClassroom(int id, String? name) async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;

      print('📤 Updating classroom: $url');
      print('📦 Request body: $body');

      final response = await http.patch(
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
          'success': true,
          'message':
              responseData['message'] ?? 'Classroom updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update classroom';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update classroom error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete classroom
  Future<Map<String, dynamic>> deleteClassroom(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms/$id');
      final headers = await _getHeaders();

      print('📤 Deleting classroom: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Classroom deleted successfully',
        };
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = (responseData is Map ? responseData['message'] : null) ??
              'Failed to delete classroom';
        } catch (e) {
          message = response.body.isNotEmpty
              ? response.body
              : 'Failed to delete classroom';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('❌ Delete classroom error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get all courses
  Future<Map<String, dynamic>> getCourses() async {
    try {
      final url = Uri.parse('$baseUrl/api/Course');
      final headers = await _getHeaders();

      print('📤 Fetching courses: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> courses = [];
        if (responseData is List) {
          courses = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          courses = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': courses,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch courses',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get courses error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get course by ID
  Future<Map<String, dynamic>> getCourseById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/Course/$id');
      final headers = await _getHeaders();

      print('📤 Fetching course: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch course',
        };
      }
    } catch (e) {
      print('❌ Get course error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Create course
  Future<Map<String, dynamic>> createCourse(String name) async {
    try {
      final url = Uri.parse('$baseUrl/api/Course');
      final headers = await _getHeaders();

      final body = {
        'name': name,
      };

      print('📤 Creating course: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Course created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to create course';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Create course error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update course
  Future<Map<String, dynamic>> updateCourse(int id, String? name) async {
    try {
      final url = Uri.parse('$baseUrl/api/Course/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;

      print('📤 Updating course: $url');
      print('📦 Request body: $body');

      final response = await http.put(
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
          'success': true,
          'message': responseData['message'] ?? 'Course updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update course';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update course error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete course
  Future<Map<String, dynamic>> deleteCourse(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/Course/$id');
      final headers = await _getHeaders();

      print('📤 Deleting course: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Course deleted successfully',
        };
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = (responseData is Map ? responseData['message'] : null) ??
              'Failed to delete course';
        } catch (e) {
          message = response.body.isNotEmpty
              ? response.body
              : 'Failed to delete course';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('❌ Delete course error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get all sections
  Future<Map<String, dynamic>> getSections() async {
    try {
      final url = Uri.parse('$baseUrl/api/sections');
      final headers = await _getHeaders();

      print('📤 Fetching sections: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> sections = [];
        if (responseData is List) {
          sections = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          sections = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': sections,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch sections',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get sections error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get section by ID
  Future<Map<String, dynamic>> getSectionById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections/$id');
      final headers = await _getHeaders();

      print('📤 Fetching section: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch section',
        };
      }
    } catch (e) {
      print('❌ Get section error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Create section
  Future<Map<String, dynamic>> createSection(String name, int courseId) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections');
      final headers = await _getHeaders();

      final body = {
        'name': name,
        'courseId': courseId,
      };

      print('📤 Creating section: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Section created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to create section';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Create section error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update section
  Future<Map<String, dynamic>> updateSection(
      int id, String? name, int? courseId) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (courseId != null) body['courseId'] = courseId;

      print('📤 Updating section: $url');
      print('📦 Request body: $body');

      final response = await http.put(
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
          'success': true,
          'message': responseData['message'] ?? 'Section updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update section';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update section error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete section
  Future<Map<String, dynamic>> deleteSection(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections/$id');
      final headers = await _getHeaders();

      print('📤 Deleting section: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Section deleted successfully',
        };
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = (responseData is Map ? responseData['message'] : null) ??
              'Failed to delete section';
        } catch (e) {
          message = response.body.isNotEmpty
              ? response.body
              : 'Failed to delete section';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('❌ Delete section error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server: $e',
      };
    }
  }

  // Get active students in a section
  Future<Map<String, dynamic>> getSectionActiveStudents(int sectionId) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections/$sectionId/active-students');
      final headers = await _getHeaders();

      print('📤 Fetching active students for section: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> students = [];
        if (responseData is List) {
          students = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          students = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': students,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch active students',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get section active students error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get all students in a section
  Future<Map<String, dynamic>> getSectionAllStudents(int sectionId) async {
    try {
      final url = Uri.parse('$baseUrl/api/sections/$sectionId/all-students');
      final headers = await _getHeaders();

      print('📤 Fetching all students for section: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> students = [];
        if (responseData is List) {
          students = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          students = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': students,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch all students',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get section all students error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get all subjects
  Future<Map<String, dynamic>> getSubjects() async {
    try {
      final url = Uri.parse('$baseUrl/api/subjects');
      final headers = await _getHeaders();

      print('📤 Fetching subjects: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> subjects = [];
        if (responseData is List) {
          subjects = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          subjects = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': subjects,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch subjects',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get subjects error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get subject by ID
  Future<Map<String, dynamic>> getSubjectById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/subjects/$id');
      final headers = await _getHeaders();

      print('📤 Fetching subject: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch subject',
        };
      }
    } catch (e) {
      print('❌ Get subject error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Create subject
  Future<Map<String, dynamic>> createSubject(String name, String code) async {
    try {
      final url = Uri.parse('$baseUrl/api/subjects');
      final headers = await _getHeaders();

      final body = {
        'name': name,
        'code': code,
      };

      print('📤 Creating subject: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Subject created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to create subject';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Create subject error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update subject
  Future<Map<String, dynamic>> updateSubject(
      int id, String? name, String? code) async {
    try {
      final url = Uri.parse('$baseUrl/api/subjects/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;

      print('📤 Updating subject: $url');
      print('📦 Request body: $body');

      final response = await http.patch(
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
          'success': true,
          'message': responseData['message'] ?? 'Subject updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update subject';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update subject error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete subject
  Future<Map<String, dynamic>> deleteSubject(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/subjects/$id');
      final headers = await _getHeaders();

      print('📤 Deleting subject: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Subject deleted successfully',
        };
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = (responseData is Map ? responseData['message'] : null) ??
              'Failed to delete subject';
        } catch (e) {
          message = response.body.isNotEmpty
              ? response.body
              : 'Failed to delete subject';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('❌ Delete subject error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Enroll a student in a section with subject
  Future<Map<String, dynamic>> enrollStudent({
    required int studentId,
    required int sectionId,
    required int subjectId,
    String? enrollmentType,
    String? academicYear,
    String? semester,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/enroll');
      final headers = await _getHeaders();

      final body = <String, dynamic>{
        'studentId': studentId,
        'sectionId': sectionId,
        'subjectId': subjectId,
        if (enrollmentType != null) 'enrollmentType': enrollmentType,
        if (academicYear != null) 'academicYear': academicYear,
        if (semester != null) 'semester': semester,
      };

      print('📤 Enrolling student: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Student enrolled successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to enroll student';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Enroll student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get enrollments for a specific student
  Future<Map<String, dynamic>> getStudentEnrollments(int studentId) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/StudentEnrollment/student/$studentId');
      final headers = await _getHeaders();

      print('📤 Fetching enrollments for student: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': null,
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData is Map
              ? responseData
              : {'enrollments': responseData},
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch student enrollments',
          'data': null,
        };
      }
    } catch (e) {
      print('❌ Get student enrollments error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': null,
      };
    }
  }

  // Get students enrolled in a section
  Future<Map<String, dynamic>> getSectionStudents(int sectionId) async {
    try {
      final url = Uri.parse(
          '$baseUrl/api/StudentEnrollment/section/$sectionId/students');
      final headers = await _getHeaders();

      print('📤 Fetching students for section: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> enrollments = [];
        if (responseData is List) {
          enrollments = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          enrollments = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': enrollments,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch section students',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get section students error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Drop an enrollment
  Future<Map<String, dynamic>> dropEnrollment(int enrollmentId) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/StudentEnrollment/$enrollmentId/drop');
      final headers = await _getHeaders();

      print('📤 Dropping enrollment: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Enrollment dropped successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to drop enrollment',
        };
      }
    } catch (e) {
      print('❌ Drop enrollment error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Re-enroll a student
  Future<Map<String, dynamic>> reenrollStudent(int enrollmentId) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/StudentEnrollment/$enrollmentId/reenroll');
      final headers = await _getHeaders();

      print('📤 Re-enrolling student: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Student re-enrolled successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to re-enroll student',
        };
      }
    } catch (e) {
      print('❌ Re-enroll student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Check if enrollment exists
  Future<Map<String, dynamic>> checkEnrollment({
    required int studentId,
    required int sectionId,
    required int subjectId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/check')
          .replace(queryParameters: {
        'studentId': studentId.toString(),
        'sectionId': sectionId.toString(),
        'subjectId': subjectId.toString(),
      });
      final headers = await _getHeaders();

      print('📤 Checking enrollment: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'exists': responseData is bool
              ? responseData
              : (responseData == true || responseData == 'true'),
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'exists': false,
          'message': 'Failed to check enrollment',
        };
      }
    } catch (e) {
      print('❌ Check enrollment error: $e');
      return {
        'success': false,
        'exists': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get all students
  Future<Map<String, dynamic>> getStudents() async {
    try {
      final url = Uri.parse('$baseUrl/api/students');
      final headers = await _getHeaders();

      print('📤 Fetching students: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> students = [];
        if (responseData is List) {
          students = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          students = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': students,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch students',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get students error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get student by ID
  Future<Map<String, dynamic>> getStudentById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/students/$id');
      final headers = await _getHeaders();

      print('📤 Fetching student: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch student',
        };
      }
    } catch (e) {
      print('❌ Get student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update student
  Future<Map<String, dynamic>> updateStudent({
    required int id,
    String? firstname,
    String? lastname,
    bool? isRegular,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/students/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (firstname != null) body['firstname'] = firstname;
      if (lastname != null) body['lastname'] = lastname;
      if (isRegular != null) body['isRegular'] = isRegular;

      print('📤 Updating student: $url');
      print('📦 Request body: $body');

      final response = await http.patch(
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
          'success': true,
          'message': responseData['message'] ?? 'Student updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update student';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete student (hard delete)
  Future<Map<String, dynamic>> deleteStudent(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/students/$id');
      final headers = await _getHeaders();

      print('📤 Deleting student: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message': responseData['message'] ?? 'Student deleted successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete student',
        };
      }
    } catch (e) {
      print('❌ Delete student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Soft delete student
  Future<Map<String, dynamic>> softDeleteStudent(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/students/$id/soft-delete');
      final headers = await _getHeaders();

      print('📤 Soft deleting student: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Student soft deleted successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to soft delete student',
        };
      }
    } catch (e) {
      print('❌ Soft delete student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Restore student
  Future<Map<String, dynamic>> restoreStudent(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/students/$id/restore');
      final headers = await _getHeaders();

      print('📤 Restoring student: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message': responseData['message'] ?? 'Student restored successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to restore student',
        };
      }
    } catch (e) {
      print('❌ Restore student error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get student's subjects
  Future<Map<String, dynamic>> getStudentSubjects() async {
    try {
      final url = Uri.parse('$baseUrl/api/students/my-subjects');
      final headers = await _getHeaders();

      print('📤 Fetching student subjects: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> subjects = [];
        if (responseData is List) {
          subjects = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          subjects = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': subjects,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch student subjects',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get student subjects error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get all instructors
  Future<Map<String, dynamic>> getInstructors() async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors');
      final headers = await _getHeaders();

      print('📤 Fetching instructors: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> instructors = [];
        if (responseData is List) {
          instructors = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          instructors = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': instructors,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch instructors',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get instructors error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get instructor by ID
  Future<Map<String, dynamic>> getInstructorById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$id');
      final headers = await _getHeaders();

      print('📤 Fetching instructor: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch instructor',
        };
      }
    } catch (e) {
      print('❌ Get instructor error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Update instructor
  Future<Map<String, dynamic>> updateInstructor({
    required int id,
    String? firstname,
    String? lastname,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$id');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (firstname != null) body['firstname'] = firstname;
      if (lastname != null) body['lastname'] = lastname;

      print('📤 Updating instructor: $url');
      print('📦 Request body: $body');

      final response = await http.patch(
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
          'success': true,
          'message':
              responseData['message'] ?? 'Instructor updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage = responseData['message']?.toString() ??
            'Failed to update instructor';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update instructor error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Delete instructor (hard delete)
  Future<Map<String, dynamic>> deleteInstructor(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$id');
      final headers = await _getHeaders();

      print('📤 Deleting instructor: $url');

      final response = await http.delete(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Instructor deleted successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete instructor',
        };
      }
    } catch (e) {
      print('❌ Delete instructor error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Soft delete instructor
  Future<Map<String, dynamic>> softDeleteInstructor(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$id/soft-delete');
      final headers = await _getHeaders();

      print('📤 Soft deleting instructor: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Instructor soft deleted successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to soft delete instructor',
        };
      }
    } catch (e) {
      print('❌ Soft delete instructor error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Restore instructor
  Future<Map<String, dynamic>> restoreInstructor(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$id/restore');
      final headers = await _getHeaders();

      print('📤 Restoring instructor: $url');

      final response = await http.patch(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Instructor restored successfully',
        };
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to restore instructor',
        };
      }
    } catch (e) {
      print('❌ Restore instructor error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get instructor's subjects
  Future<Map<String, dynamic>> getInstructorSubjects(int instructorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/$instructorId/subjects');
      final headers = await _getHeaders();

      print('📤 Fetching instructor subjects: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> subjects = [];
        if (responseData is List) {
          subjects = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          subjects = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': subjects,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch instructor subjects',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get instructor subjects error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Get instructor profile
  Future<Map<String, dynamic>> getInstructorProfile() async {
    try {
      final url = Uri.parse('$baseUrl/api/instructors/profile');
      final headers = await _getHeaders();

      print('📤 Fetching instructor profile: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch instructor profile',
        };
      }
    } catch (e) {
      print('❌ Get instructor profile error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get all schedules
  Future<Map<String, dynamic>> getSchedules() async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules');
      final headers = await _getHeaders();

      print('📤 Fetching schedules: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> schedules = [];
        if (responseData is List) {
          schedules = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          schedules = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': schedules,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch schedules',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get schedules error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }

  // Create schedule
  Future<Map<String, dynamic>> createSchedule({
    required String timeIn,
    required String timeOut,
    required String dayOfWeek,
    required int subjectId,
    required int classroomId,
    required int sectionId,
    required int instructorId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules');
      final headers = await _getHeaders();

      final body = {
        'timeIn': timeIn,
        'timeOut': timeOut,
        'dayOfWeek': dayOfWeek,
        'subjectId': subjectId,
        'classroomId': classroomId,
        'sectionId': sectionId,
        'instructorId': instructorId,
      };

      print('📤 Creating schedule: $url');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Schedule created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to create schedule';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Create schedule error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  Future<Map<String, dynamic>> updateSchedule(
    int id, {
    required String timeIn,
    required String timeOut,
    required String dayOfWeek,
    required int subjectId,
    required int classroomId,
    required int sectionId,
    required int instructorId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules/$id');
      final headers = await _getHeaders();

      final body = {
        'timeIn': timeIn,
        'timeOut': timeOut,
        'dayOfWeek': dayOfWeek,
        'subjectId': subjectId,
        'classroomId': classroomId,
        'sectionId': sectionId,
        'instructorId': instructorId,
      };

      print('📤 Updating schedule: $url');
      print('📦 Request body: $body');

      final response = await http.put(
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
          'success': true,
          'message': responseData['message'] ?? 'Schedule updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage =
            responseData['message']?.toString() ?? 'Failed to update schedule';
        Map<String, List<String>>? fieldErrors;

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          fieldErrors = {};
          final errorList = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              final msgs = value.map((e) => e.toString()).toList();
              fieldErrors![key] = msgs;
              errorList.addAll(msgs);
            }
          });

          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': fieldErrors,
        };
      }
    } catch (e) {
      print('❌ Update schedule error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  Future<Map<String, dynamic>> deleteSchedule(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules/$id');
      final headers = await _getHeaders();

      print('📤 Deleting schedule: $url');

      final response = await http.delete(
        url,
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Schedule deleted successfully',
        };
      } else {
        if (response.body.isEmpty) {
          return {
            'success': false,
            'message':
                'Failed to delete schedule. Status: ${response.statusCode}',
          };
        }
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to delete schedule',
          };
        } catch (e) {
          return {
            'success': false,
            'message': response.body, // Return raw body if not JSON
          };
        }
      }
    } catch (e) {
      print('❌ Delete schedule error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get schedule by ID
  Future<Map<String, dynamic>> getScheduleById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules/$id');
      final headers = await _getHeaders();

      print('📤 Fetching schedule: $url');
      final response = await http.get(url, headers: headers);
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
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch schedule',
        };
      }
    } catch (e) {
      print('❌ Get schedule error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
      };
    }
  }

  // Get instructor schedules
  Future<Map<String, dynamic>> getInstructorSchedules(int instructorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/schedules/$instructorId/all');
      final headers = await _getHeaders();

      print('📤 Fetching instructor schedules: $url');
      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> schedules = [];
        if (responseData is List) {
          schedules = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          schedules = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': schedules,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ??
              'Failed to fetch instructor schedules',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Get instructor schedules error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
      };
    }
  }
}
