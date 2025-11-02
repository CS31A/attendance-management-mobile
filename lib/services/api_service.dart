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

  // Get list of users - fetches from separate endpoints for instructors, students, and admins
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final headers = await _getHeaders();
      final List<Map<String, dynamic>> allUsers = [];
      
      // Fetch instructors (teachers)
      try {
        final instructorsUrl = Uri.parse('$baseUrl/api/instructors');
        print('📤 Fetching instructors (teachers): $instructorsUrl');
        
        final instructorsResponse = await http.get(instructorsUrl, headers: headers);
        print('📥 Instructors response status: ${instructorsResponse.statusCode}');
        print('📥 Instructors response body: ${instructorsResponse.body}');
        
        if (instructorsResponse.statusCode == 200 && instructorsResponse.body.isNotEmpty) {
          final instructorsData = jsonDecode(instructorsResponse.body);
          List<Map<String, dynamic>> instructors = [];
          
          if (instructorsData is List) {
            instructors = List<Map<String, dynamic>>.from(instructorsData);
          } else if (instructorsData is Map<String, dynamic> && instructorsData.containsKey('data')) {
            instructors = List<Map<String, dynamic>>.from(instructorsData['data']);
          } else if (instructorsData is Map<String, dynamic>) {
            // Try to find array data in the response
            print('⚠️ Unexpected instructors response format: $instructorsData');
          }
          
          if (instructors.isEmpty) {
            print('⚠️ No instructors found in response');
          }
          
          final instructorsCount = instructors.length;
          
          // Map instructors to user format with role
          for (var instructor in instructors) {
            final user = Map<String, dynamic>.from(instructor);
            user['role'] = 'Teacher';
            // Map userId if it exists
            if (instructor.containsKey('userId')) {
              user['id'] = instructor['userId'];
            }
            // Combine firstname and lastname into name fields if needed
            if (instructor.containsKey('firstname') || instructor.containsKey('lastname')) {
              final firstname = instructor['firstname']?.toString() ?? '';
              final lastname = instructor['lastname']?.toString() ?? '';
              user['firstname'] = firstname;
              user['lastname'] = lastname;
              user['name'] = '$firstname $lastname'.trim();
            }
            allUsers.add(user);
          }
          print('✅ Fetched $instructorsCount instructors');
        } else {
          print('⚠️ Instructors endpoint returned status ${instructorsResponse.statusCode}');
        }
      } catch (e) {
        print('⚠️ Error fetching instructors: $e');
      }
      
      // Fetch students
      try {
        final studentsUrl = Uri.parse('$baseUrl/api/students');
        print('📤 Fetching students: $studentsUrl');
        
        final studentsResponse = await http.get(studentsUrl, headers: headers);
        print('📥 Students response status: ${studentsResponse.statusCode}');
        
        print('📥 Students response body: ${studentsResponse.body}');
        
        if (studentsResponse.statusCode == 200 && studentsResponse.body.isNotEmpty) {
          final studentsData = jsonDecode(studentsResponse.body);
          List<Map<String, dynamic>> students = [];
          
          if (studentsData is List) {
            students = List<Map<String, dynamic>>.from(studentsData);
          } else if (studentsData is Map<String, dynamic> && studentsData.containsKey('data')) {
            students = List<Map<String, dynamic>>.from(studentsData['data']);
          } else if (studentsData is Map<String, dynamic>) {
            // Try to find array data in the response
            print('⚠️ Unexpected students response format: $studentsData');
          }
          
          if (students.isEmpty && studentsResponse.statusCode == 200) {
            print('⚠️ No students found in response (empty array is valid)');
          }
          
          final studentsCount = students.length;
          
          // Map students to user format with role
          for (var student in students) {
            final user = Map<String, dynamic>.from(student);
            user['role'] = 'Student';
            // Map userId if it exists
            if (student.containsKey('userId')) {
              user['id'] = student['userId'];
            }
            // Combine firstname and lastname into name fields if needed
            if (student.containsKey('firstname') || student.containsKey('lastname')) {
              final firstname = student['firstname']?.toString() ?? '';
              final lastname = student['lastname']?.toString() ?? '';
              user['firstname'] = firstname;
              user['lastname'] = lastname;
              user['name'] = '$firstname $lastname'.trim();
            }
            allUsers.add(user);
          }
          print('✅ Fetched $studentsCount students');
        }
      } catch (e) {
        print('⚠️ Error fetching students: $e');
      }
      
      // Fetch admins (if endpoint exists)
      try {
        final adminsUrl = Uri.parse('$baseUrl/api/admin');
        print('📤 Fetching admins: $adminsUrl');
        
        final adminsResponse = await http.get(adminsUrl, headers: headers);
        print('📥 Admins response status: ${adminsResponse.statusCode}');
        
        if (adminsResponse.statusCode == 200 && adminsResponse.body.isNotEmpty) {
          final adminsData = jsonDecode(adminsResponse.body);
          List<Map<String, dynamic>> admins = [];
          
          if (adminsData is List) {
            admins = List<Map<String, dynamic>>.from(adminsData);
          } else if (adminsData is Map<String, dynamic> && adminsData.containsKey('data')) {
            admins = List<Map<String, dynamic>>.from(adminsData['data']);
          }
          
          final adminsCount = admins.length;
          
          // Map admins to user format with role
          for (var admin in admins) {
            final user = Map<String, dynamic>.from(admin);
            user['role'] = 'Admin';
            if (admin.containsKey('userId')) {
              user['id'] = admin['userId'];
            }
            if (admin.containsKey('firstname') || admin.containsKey('lastname')) {
              final firstname = admin['firstname']?.toString() ?? '';
              final lastname = admin['lastname']?.toString() ?? '';
              user['firstname'] = firstname;
              user['lastname'] = lastname;
              user['name'] = '$firstname $lastname'.trim();
            }
            allUsers.add(user);
          }
          print('✅ Fetched $adminsCount admins');
        }
      } catch (e) {
        print('⚠️ Error fetching admins (endpoint might not exist): $e');
      }
      
      print('✅ Total users fetched: ${allUsers.length}');
      
      return {
        'success': true,
        'data': allUsers,
      };
    } catch (e) {
      print('❌ Get users error: $e');
      
      return {
        'success': false,
        'message': 'Failed to connect to server.',
        'data': [],
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

