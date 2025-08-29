import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppData {
  // Central in-memory stores
  static final ValueNotifier<List<Map<String, String>>> teachers = ValueNotifier<List<Map<String, String>>>([
    {'name': 'John Smith', 'email': 'john.smith@school.edu', 'subject': 'Mathematics', 'status': 'Active'},
    {'name': 'Sarah Johnson', 'email': 'sarah.johnson@school.edu', 'subject': 'English', 'status': 'Active'},
    {'name': 'Michael Brown', 'email': 'michael.brown@school.edu', 'subject': 'Science', 'status': 'Active'},
  ]);

  static final ValueNotifier<List<Map<String, String>>> students = ValueNotifier<List<Map<String, String>>>([
    {'name': 'Emma Wilson', 'email': 'emma.wilson@student.edu', 'grade': 'Grade 10', 'status': 'Active'},
    {'name': 'David Lee', 'email': 'david.lee@student.edu', 'grade': 'Grade 11', 'status': 'Active'},
    {'name': 'Lisa Chen', 'email': 'lisa.chen@student.edu', 'grade': 'Grade 9', 'status': 'Active'},
    {'name': 'Alex Rodriguez', 'email': 'alex.rodriguez@student.edu', 'grade': 'Grade 12', 'status': 'Active'},
  ]);

  // Users management mixed list
  static final ValueNotifier<List<Map<String, dynamic>>> users = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'name': 'Olivia Rhye',
      'email': 'olivia@untitledui.com',
      'role': 'Admin',
      'status': 'Active',
      'phone': '+1 (555) 123-4567',
      'color': Colors.blue,
    },
    {
      'name': 'Phoenix Baker',
      'email': 'phoenix@untitledui.com',
      'role': 'Teacher',
      'status': 'Active',
      'phone': '+1 (555) 654-0198',
      'color': Colors.purple,
    },
    {
      'name': 'Lana Steiner',
      'email': 'lana@untitledui.com',
      'role': 'Student',
      'status': 'Inactive',
      'phone': '+1 (555) 987-0001',
      'color': Colors.teal,
    },
    {
      'name': 'Candice Wu',
      'email': 'candice@untitledui.com',
      'role': 'Student',
      'status': 'Pending',
      'phone': '+1 (555) 111-2222',
      'color': Colors.orange,
    },
  ]);

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
}

class AppStorage {
  static const String keyTeachers = 'app_teachers';
  static const String keyStudents = 'app_students';
  static const String keyUsers = 'app_users';
  static const String keyLoggedIn = 'app_logged_in';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load teachers
    final t = prefs.getString(keyTeachers);
    if (t != null) {
      final decoded = (jsonDecode(t) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
      AppData.teachers.value = decoded;
    }

    // Load students
    final s = prefs.getString(keyStudents);
    if (s != null) {
      final decoded = (jsonDecode(s) as List).cast<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
      AppData.students.value = decoded;
    }

    // Load users
    final u = prefs.getString(keyUsers);
    if (u != null) {
      final decoded = (jsonDecode(u) as List).cast<Map>().map((e) {
        final map = e.map((k, v) => MapEntry(k.toString(), v));
        final dynamic colorVal = map['color'];
        if (colorVal is int) {
          map['color'] = Color(colorVal);
        } else if (colorVal is String) {
          // In case of stringified int, try parse
          final parsed = int.tryParse(colorVal);
          if (parsed != null) map['color'] = Color(parsed);
        }
        return map;
      }).toList().cast<Map<String, dynamic>>();
      AppData.users.value = decoded;
    }

    // Wire auto-save
    AppData.teachers.addListener(save);
    AppData.students.addListener(save);
    AppData.users.addListener(save);
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyTeachers, jsonEncode(AppData.teachers.value));
    await prefs.setString(keyStudents, jsonEncode(AppData.students.value));
    await prefs.setString(keyUsers, jsonEncode(AppData.users.value.map((e) => {
      'name': e['name'],
      'email': e['email'],
      'role': e['role'],
      'status': e['status'],
      'phone': e['phone'],
      // Colors are not JSON-serializable, store as int value
      'color': (e['color'] is Color) ? (e['color'] as Color).value : Colors.blue.value,
    }).toList()));
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



