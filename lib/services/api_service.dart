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
}

