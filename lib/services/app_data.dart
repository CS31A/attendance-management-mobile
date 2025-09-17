import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;

class AppData {
  // Central in-memory stores - start with empty lists
  static final ValueNotifier<List<Map<String, String>>> teachers = ValueNotifier<List<Map<String, String>>>([]);

  static final ValueNotifier<List<Map<String, String>>> students = ValueNotifier<List<Map<String, String>>>([]);

  // Users management mixed list - start with empty list
  static final ValueNotifier<List<Map<String, dynamic>>> users = ValueNotifier<List<Map<String, dynamic>>>([]);

  static Future<void> addTeacher(Map<String, String> teacher) async {
    final list = List<Map<String, String>>.from(teachers.value)..add(teacher);
    teachers.value = list;
    await AppStorage.save();
  }

  static Future<void> addStudent(Map<String, String> student) async {
    final list = List<Map<String, String>>.from(students.value)..add(student);
    students.value = list;
    await AppStorage.save();
  }

  static Future<void> deleteByEmail(String email) async {
    // Remove from teachers
    final newTeachers = List<Map<String, String>>.from(teachers.value)
      ..removeWhere((t) => (t['email'] ?? '').toLowerCase() == email.toLowerCase());
    if (!_listEqualsMap(teachers.value, newTeachers)) {
      teachers.value = newTeachers;
    }

    // Remove from students
    final newStudents = List<Map<String, String>>.from(students.value)
      ..removeWhere((s) => (s['email'] ?? '').toLowerCase() == email.toLowerCase());
    if (!_listEqualsMap(students.value, newStudents)) {
      students.value = newStudents;
    }

    // Remove from users
    final newUsers = List<Map<String, dynamic>>.from(users.value)
      ..removeWhere((u) => (u['email'] ?? '').toLowerCase() == email.toLowerCase());
    if (!_listEqualsDynamic(users.value, newUsers)) {
      users.value = newUsers;
    }

    await AppStorage.save();
  }

  static Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    final email = updatedUser['email']?.toString().toLowerCase();
    if (email == null) return;

    // Update in users list
    final newUsers = List<Map<String, dynamic>>.from(users.value);
    final userIndex = newUsers.indexWhere((u) => (u['email'] ?? '').toLowerCase() == email);
    if (userIndex != -1) {
      newUsers[userIndex] = updatedUser;
      users.value = newUsers;
    }

    // Update in role-specific lists
    final role = updatedUser['role']?.toString();
    final name = updatedUser['name']?.toString();
    final phone = updatedUser['phone']?.toString();

    if (role == 'Teacher') {
      final newTeachers = List<Map<String, String>>.from(teachers.value);
      final teacherIndex = newTeachers.indexWhere((t) => (t['email'] ?? '').toLowerCase() == email);
      if (teacherIndex != -1) {
        newTeachers[teacherIndex] = {
          'name': name ?? '',
          'email': email,
          'subject': newTeachers[teacherIndex]['subject'] ?? 'N/A',
          'status': 'Active',
        };
        teachers.value = newTeachers;
      }
    } else if (role == 'Student') {
      final newStudents = List<Map<String, String>>.from(students.value);
      final studentIndex = newStudents.indexWhere((s) => (s['email'] ?? '').toLowerCase() == email);
      if (studentIndex != -1) {
        newStudents[studentIndex] = {
          'name': name ?? '',
          'email': email,
          'grade': newStudents[studentIndex]['grade'] ?? 'Grade',
          'status': 'Active',
        };
        students.value = newStudents;
      }
    }

    await AppStorage.save();
  }

  static bool _listEqualsMap(List<Map<String, String>> a, List<Map<String, String>> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!mapEquals(a[i], b[i])) return false;
    }
    return true;
  }

  static bool _listEqualsDynamic(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!mapEquals(a[i], b[i])) return false;
    }
    return true;
  }

  // Debug method to check what's stored
  static Future<void> debugStorage() async {
    try {
      print('=== DEBUG STORAGE ===');
      print('Current teachers in memory: ${teachers.value.length}');
      print('Current students in memory: ${students.value.length}');
      print('Current users in memory: ${users.value.length}');
      
      if (kIsWeb) {
        // Check localStorage for web
        final teachersData = html.window.localStorage['app_teachers'];
        final studentsData = html.window.localStorage['app_students'];
        final usersData = html.window.localStorage['app_users'];
        
        print('Teachers in localStorage: ${teachersData ?? "null"}');
        print('Students in localStorage: ${studentsData ?? "null"}');
        print('Users in localStorage: ${usersData ?? "null"}');
      } else {
        // Check SharedPreferences for mobile/desktop
        final prefs = await SharedPreferences.getInstance();
        final teachersData = prefs.getString('app_teachers');
        final studentsData = prefs.getString('app_students');
        final usersData = prefs.getString('app_users');
        
        print('Teachers in SharedPreferences: ${teachersData ?? "null"}');
        print('Students in SharedPreferences: ${studentsData ?? "null"}');
        print('Users in SharedPreferences: ${usersData ?? "null"}');
      }
      print('=====================');
    } catch (e) {
      print('Debug storage error: $e');
    }
  }
}

class AppStorage {
  static const String keyTeachers = 'app_teachers';
  static const String keyStudents = 'app_students';
  static const String keyUsers = 'app_users';
  static const String keyLoggedIn = 'app_logged_in';

  static Future<void> init() async {
    try {
      if (kIsWeb) {
        // Load from localStorage for web platform
        print('Loading data from localStorage (web)...');
        
        final teachersData = html.window.localStorage['app_teachers'];
        if (teachersData != null) {
          final decoded = (jsonDecode(teachersData) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
          AppData.teachers.value = decoded;
          print('Loaded ${decoded.length} teachers from localStorage');
        }
        
        final studentsData = html.window.localStorage['app_students'];
        if (studentsData != null) {
          final decoded = (jsonDecode(studentsData) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
          AppData.students.value = decoded;
          print('Loaded ${decoded.length} students from localStorage');
        }
        
        final usersData = html.window.localStorage['app_users'];
        if (usersData != null) {
          final decoded = (jsonDecode(usersData) as List).cast<Map>().map((e) {
            final map = e.map((k, v) => MapEntry(k.toString(), v));
            final dynamic colorVal = map['color'];
            if (colorVal is int) {
              map['color'] = Color(colorVal);
            } else if (colorVal is String) {
              final parsed = int.tryParse(colorVal);
              if (parsed != null) map['color'] = Color(parsed);
            }
            return map;
          }).toList().cast<Map<String, dynamic>>();
          AppData.users.value = decoded;
          print('Loaded ${decoded.length} users from localStorage');
        }
        
        print('Web data loading complete');
      } else {
        // Load from SharedPreferences for mobile/desktop
        print('Loading data from SharedPreferences (mobile/desktop)...');
        final prefs = await SharedPreferences.getInstance();

        final t = prefs.getString(keyTeachers);
        if (t != null) {
          final decoded = (jsonDecode(t) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
          AppData.teachers.value = decoded;
        }

        final s = prefs.getString(keyStudents);
        if (s != null) {
          final decoded = (jsonDecode(s) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
          AppData.students.value = decoded;
        }

        final u = prefs.getString(keyUsers);
        if (u != null) {
          final decoded = (jsonDecode(u) as List).cast<Map>().map((e) {
            final map = e.map((k, v) => MapEntry(k.toString(), v));
            final dynamic colorVal = map['color'];
            if (colorVal is int) {
              map['color'] = Color(colorVal);
            } else if (colorVal is String) {
              final parsed = int.tryParse(colorVal);
              if (parsed != null) map['color'] = Color(parsed);
            }
            return map;
          }).toList().cast<Map<String, dynamic>>();
          AppData.users.value = decoded;
        }
        
        print('Mobile/desktop data loading complete');
      }

      // Wire auto-save
      AppData.teachers.addListener(save);
      AppData.students.addListener(save);
      AppData.users.addListener(save);
      
    } catch (e) {
      print('Error initializing AppStorage: $e');
    }
  }

  static Future<void> save() async {
    try {
      if (kIsWeb) {
        // Use localStorage for web platform
        html.window.localStorage['app_teachers'] = jsonEncode(AppData.teachers.value);
        html.window.localStorage['app_students'] = jsonEncode(AppData.students.value);
        html.window.localStorage['app_users'] = jsonEncode(AppData.users.value.map((e) => {
          'name': e['name'],
          'email': e['email'],
          'role': e['role'],
          'status': e['status'],
          'phone': e['phone'],
          'color': (e['color'] is Color) ? (e['color'] as Color).value : Colors.blue.value,
        }).toList());
        print('Data saved to localStorage (web)');
      } else {
        // Use SharedPreferences for mobile/desktop
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyTeachers, jsonEncode(AppData.teachers.value));
        await prefs.setString(keyStudents, jsonEncode(AppData.students.value));
        await prefs.setString(keyUsers, jsonEncode(AppData.users.value.map((e) => {
          'name': e['name'],
          'email': e['email'],
          'role': e['role'],
          'status': e['status'],
          'phone': e['phone'],
          'color': (e['color'] is Color) ? (e['color'] as Color).value : Colors.blue.value,
        }).toList()));
        print('Data saved to SharedPreferences (mobile/desktop)');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoggedIn) ?? false;
  }
}


