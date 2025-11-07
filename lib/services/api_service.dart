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

  // Refresh access token
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
      print('📦 Request body: ${body.map((k, v) => MapEntry(k, k == 'refreshToken' || k == 'oldAccessToken' ? (v != null ? '${v.toString().substring(0, v.toString().length > 20 ? 20 : v.toString().length)}...' : null) : v))}');

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
        if (responseData['success'] == true && responseData['accessToken'] != null) {
          await StorageService.saveTokens(
            responseData['accessToken'] as String,
            responseData['refreshToken'] as String? ?? refreshTokenValue,
          );
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
        'message': 'Failed to connect to server. Please check your internet connection.',
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
        'message': 'Failed to connect to server. Please check your internet connection.',
      };
    }
  }

  // Get list of users from /api/users endpoint
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/users');
      
      print('📤 Fetching users from /api/users: $url');
      
      final response = await http.get(url, headers: headers);
      print('📥 Users response status: ${response.statusCode}');
      print('📥 Users response body: ${response.body}');
      
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);
        List<Map<String, dynamic>> users = [];
        
        // Handle different response formats
        if (responseData is List) {
          users = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          users = List<Map<String, dynamic>>.from(responseData['data']);
        } else if (responseData is Map<String, dynamic>) {
          print('⚠️ Unexpected users response format: $responseData');
        }
        
        // Normalize user data format
        final normalizedUsers = users.map((user) {
          final normalized = Map<String, dynamic>.from(user);
          
          // Map userId to id if needed
          if (normalized.containsKey('userId') && !normalized.containsKey('id')) {
            normalized['id'] = normalized['userId'];
          }
          
          // Ensure role is properly formatted
          if (normalized.containsKey('role')) {
            final role = normalized['role']?.toString() ?? '';
            // Capitalize first letter
            if (role.isNotEmpty) {
              normalized['role'] = role[0].toUpperCase() + role.substring(1).toLowerCase();
            }
          }
          
          // Combine firstname and lastname into name field if needed
          if (normalized.containsKey('firstname') || normalized.containsKey('lastname')) {
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
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
          'data': [],
        };
      } else {
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : <String, dynamic>{};
        
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch users',
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
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/account/me');

      print('📤 Fetching current account: $url');
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
      final headers = await _getHeaders();

      final body = <String, dynamic>{
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (email != null) 'email': email,
        if (currentPassword != null) 'currentPassword': currentPassword,
        if (newPassword != null) 'newPassword': newPassword,
        if (confirmNewPassword != null) 'confirmNewPassword': confirmNewPassword,
        if (sectionId != null) 'sectionId': sectionId,
        if (isRegular != null) 'isRegular': isRegular,
      };

      print('📤 Updating profile: $url');
      print('📦 Request body: ${Map<String, dynamic>.from(body)..updateAll((k, v) => k.toLowerCase().contains('password') ? '***' : v)}');

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
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'updatedProfile': responseData['updatedProfile'],
        };
      } else {
        String errorMessage = responseData['message']?.toString() ?? 'Failed to update profile';
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
      final headers = await _getHeaders();

      print('📤 Logging out: $url');

      final response = await http.post(
        url,
        headers: headers,
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

  // Get all classrooms
  Future<Map<String, dynamic>> getClassrooms() async {
    try {
      final url = Uri.parse('$baseUrl/api/classrooms');
      final headers = await _getHeaders();

      print('📤 Fetching classrooms: $url');
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
        List<Map<String, dynamic>> classrooms = [];
        if (responseData is List) {
          classrooms = List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          classrooms = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': classrooms,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch classrooms',
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
          'message': responseData['message'] ?? 'Classroom created successfully',
          'data': responseData,
        };
      } else {
        String errorMessage = responseData['message']?.toString() ?? 'Failed to create classroom';
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
          'message': responseData['message'] ?? 'Classroom updated successfully',
          'data': responseData,
        };
      } else {
        String errorMessage = responseData['message']?.toString() ?? 'Failed to update classroom';
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
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete classroom',
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          courses = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': courses,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch courses',
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to create course';
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to update course';
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
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete course',
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          sections = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': sections,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch sections',
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to create section';
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
  Future<Map<String, dynamic>> updateSection(int id, String? name, int? courseId) async {
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to update section';
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
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete section',
        };
      }
    } catch (e) {
      print('❌ Delete section error: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server.',
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          students = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': students,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch active students',
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          students = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': students,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch all students',
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          subjects = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': subjects,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch subjects',
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to create subject';
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
  Future<Map<String, dynamic>> updateSubject(int id, String? name, String? code) async {
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to update subject';
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
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete subject',
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
        String errorMessage = responseData['message']?.toString() ?? 'Failed to enroll student';
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
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/student/$studentId');
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
          'data': responseData is Map ? responseData : {'enrollments': responseData},
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch student enrollments',
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
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/section/$sectionId/students');
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
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          enrollments = List<Map<String, dynamic>>.from(responseData['data']);
        }

        return {
          'success': true,
          'data': enrollments,
        };
      } else {
        return {
          'success': false,
          'message': (responseData is Map ? responseData['message'] : null) ?? 'Failed to fetch section students',
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
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/$enrollmentId/drop');
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
      final url = Uri.parse('$baseUrl/api/StudentEnrollment/$enrollmentId/reenroll');
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
          'exists': responseData is bool ? responseData : (responseData == true || responseData == 'true'),
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
}

