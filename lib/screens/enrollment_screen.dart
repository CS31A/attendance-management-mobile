import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EnrollmentScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const EnrollmentScreen({super.key, this.onBackPressed});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _enrollments = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStudents(),
      _loadSections(),
      _loadSubjects(),
    ]);
    // Load enrollments for the first section if available
    if (_sections.isNotEmpty && _selectedSectionId == null) {
      _selectedSectionId = _sections.first['id']?.toString() ?? 
                          _sections.first['sectionId']?.toString();
      await _loadEnrollments();
    }
  }

  Future<void> _loadEnrollments() async {
    if (_selectedSectionId == null) {
      setState(() {
        _enrollments = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sectionId = int.tryParse(_selectedSectionId ?? '');
      if (sectionId == null) {
        setState(() {
          _enrollments = [];
          _isLoading = false;
        });
        return;
      }

      final response = await _apiService.getSectionStudents(sectionId);
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _enrollments = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _enrollments = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load enrollments';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load enrollments: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudents() async {
    try {
      final response = await _apiService.getUsers();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _students = List<Map<String, dynamic>>.from(data)
                .where((user) => (user['role']?.toString().toLowerCase() ?? '') == 'student')
                .toList();
          });
        }
      }
    } catch (e) {
      print('⚠️ Error loading students: $e');
    }
  }

  Future<void> _loadSections() async {
    try {
      final response = await _apiService.getSections();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _sections = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print('⚠️ Error loading sections: $e');
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final response = await _apiService.getSubjects();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _subjects = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print('⚠️ Error loading subjects: $e');
    }
  }

  String _getSectionName(int? sectionId) {
    if (sectionId == null) return 'Unknown Section';
    final section = _sections.firstWhere(
      (s) => s['id'] == sectionId || s['sectionId'] == sectionId,
      orElse: () => <String, dynamic>{},
    );
    return section['name']?.toString() ?? 'Section $sectionId';
  }

  String _getSubjectName(int? subjectId) {
    if (subjectId == null) return 'Unknown Subject';
    final subject = _subjects.firstWhere(
      (s) => s['id'] == subjectId || s['subjectId'] == subjectId,
      orElse: () => <String, dynamic>{},
    );
    final name = subject['name']?.toString() ?? '';
    final code = subject['code']?.toString() ?? '';
    if (name.isNotEmpty && code.isNotEmpty) {
      return '$code - $name';
    }
    return name.isNotEmpty ? name : (code.isNotEmpty ? code : 'Subject $subjectId');
  }

  String _getStudentName(Map<String, dynamic> enrollment) {
    final studentId = enrollment['studentId']?.toString();
    if (studentId == null) return 'Unknown Student';
    
    final student = _students.firstWhere(
      (s) => s['id']?.toString() == studentId || 
            s['userId']?.toString() == studentId,
      orElse: () => <String, dynamic>{},
    );
    
    if (student['firstname'] != null || student['lastname'] != null) {
      final firstname = student['firstname']?.toString() ?? '';
      final lastname = student['lastname']?.toString() ?? '';
      return '$firstname $lastname'.trim();
    }
    return student['name']?.toString() ?? 
           student['username']?.toString() ?? 
           'Student $studentId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Section Selector
              if (!_isLoading && _errorMessage == null)
                _buildSectionSelector(),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadEnrollments,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _buildEnrollmentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ACLC Logo
          SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              'assets/acla logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const Expanded(
            child: Text(
              'Enrollment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _openAddEnrollment,
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String?>(
                value: _selectedSectionId,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF1E3A8A),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                hint: const Text(
                  'Select a section',
                  style: TextStyle(color: Colors.white70),
                ),
                items: _sections.map((section) {
                  final sectionId = section['id']?.toString() ?? 
                                  section['sectionId']?.toString() ?? '';
                  final sectionName = section['name']?.toString() ?? 'Section $sectionId';
                  return DropdownMenuItem(
                    value: sectionId,
                    child: Text(sectionName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSectionId = value;
                  });
                  _loadEnrollments();
                },
                icon: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsList() {
    if (_selectedSectionId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a section to view enrollments',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No enrollments found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to enroll a student',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = _enrollments[index];
        return _buildEnrollmentCard(enrollment);
      },
    );
  }

  Widget _buildEnrollmentCard(Map<String, dynamic> enrollment) {
    final studentName = _getStudentName(enrollment);
    final sectionName = _getSectionName(enrollment['sectionId']);
    final subjectName = _getSubjectName(enrollment['subjectId']);
    final enrollmentId = enrollment['id']?.toString() ?? 
                        enrollment['enrollmentId']?.toString() ?? '';
    final isActive = enrollment['isActive'] ?? true;
    final enrollmentDate = enrollment['enrolledAt'] ?? 
                          enrollment['createdAt'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Student Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.class_,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sectionName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.book,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (enrollmentDate.toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(enrollmentDate.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Status Badge & Actions
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : 'Dropped',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    IconButton(
                      onPressed: () => _reenrollStudent(enrollmentId),
                      icon: const Icon(Icons.refresh),
                      color: Colors.blue[400],
                      iconSize: 20,
                      tooltip: 'Re-enroll',
                    ),
                  IconButton(
                    onPressed: () => isActive 
                        ? _dropEnrollment(enrollmentId)
                        : _removeEnrollment(enrollmentId),
                    icon: Icon(isActive ? Icons.cancel_outlined : Icons.delete_outline),
                    color: Colors.red[400],
                    iconSize: 20,
                    tooltip: isActive ? 'Drop' : 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _openAddEnrollment() async {
    if (_students.isEmpty || _sections.isEmpty || _subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while data is loading...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEnrollmentModal(
        students: _students,
        sections: _sections,
        subjects: _subjects,
        defaultSectionId: _selectedSectionId != null 
            ? int.tryParse(_selectedSectionId!) 
            : null,
        onEnrolled: () {
          _loadEnrollments();
        },
      ),
    );
  }

  Future<void> _dropEnrollment(String enrollmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drop Enrollment'),
        content: const Text('Are you sure you want to drop this enrollment? The student can be re-enrolled later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Drop'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      final enrollmentIdInt = int.tryParse(enrollmentId);
      if (enrollmentIdInt == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid enrollment ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await _apiService.dropEnrollment(enrollmentIdInt);
      
      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Enrollment dropped successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadEnrollments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to drop enrollment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reenrollStudent(String enrollmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-enroll Student'),
        content: const Text('Are you sure you want to re-enroll this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Re-enroll'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      final enrollmentIdInt = int.tryParse(enrollmentId);
      if (enrollmentIdInt == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid enrollment ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await _apiService.reenrollStudent(enrollmentIdInt);
      
      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Student re-enrolled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadEnrollments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to re-enroll student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeEnrollment(String enrollmentId) async {
      final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Enrollment'),
        content: const Text('Are you sure you want to permanently delete this enrollment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Note: The API doesn't have a delete endpoint, so we'll use drop
      final enrollmentIdInt = int.tryParse(enrollmentId);
      if (enrollmentIdInt != null) {
        await _dropEnrollment(enrollmentId);
      }
    }
  }
}

class _AddEnrollmentModal extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> subjects;
  final int? defaultSectionId;
  final VoidCallback onEnrolled;

  const _AddEnrollmentModal({
    required this.students,
    required this.sections,
    required this.subjects,
    this.defaultSectionId,
    required this.onEnrolled,
  });

  @override
  State<_AddEnrollmentModal> createState() => _AddEnrollmentModalState();
}

class _AddEnrollmentModalState extends State<_AddEnrollmentModal> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  int? _selectedStudentId;
  int? _selectedSectionId;
  int? _selectedSubjectId;
  String? _enrollmentType;
  String? _academicYear;
  String? _semester;
  bool _isEnrolling = false;

  @override
  void initState() {
    super.initState();
    if (widget.defaultSectionId != null) {
      _selectedSectionId = widget.defaultSectionId;
    }
  }

  String _getStudentName(Map<String, dynamic> student) {
    if (student['firstname'] != null || student['lastname'] != null) {
      final firstname = student['firstname']?.toString() ?? '';
      final lastname = student['lastname']?.toString() ?? '';
      return '$firstname $lastname'.trim();
    }
    return student['name']?.toString() ?? 
           student['username']?.toString() ?? 
           'Unknown Student';
  }

  String _getStudentDisplay(Map<String, dynamic> student) {
    final name = _getStudentName(student);
    final email = student['email']?.toString() ?? '';
    return email.isNotEmpty ? '$name ($email)' : name;
  }

  Future<void> _handleEnroll() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudentId == null || _selectedSectionId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select student, section, and subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if enrollment already exists
    final checkResponse = await _apiService.checkEnrollment(
      studentId: _selectedStudentId!,
      sectionId: _selectedSectionId!,
      subjectId: _selectedSubjectId!,
    );

    if (checkResponse['success'] == true && checkResponse['exists'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This enrollment already exists'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isEnrolling = true;
    });

    final response = await _apiService.enrollStudent(
      studentId: _selectedStudentId!,
      sectionId: _selectedSectionId!,
      subjectId: _selectedSubjectId!,
      enrollmentType: _enrollmentType?.isEmpty == true ? null : _enrollmentType,
      academicYear: _academicYear?.isEmpty == true ? null : _academicYear,
      semester: _semester?.isEmpty == true ? null : _semester,
    );

    setState(() {
      _isEnrolling = false;
    });

    if (response['success'] == true) {
      widget.onEnrolled();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Student enrolled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to enroll student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Enroll Student',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Dropdown
                      const Text(
                        'Student *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedStudentId,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select a student',
                          ),
                          items: widget.students.map((student) {
                            final studentId = student['id'] ?? student['userId'];
                            final studentIdInt = studentId is int 
                                ? studentId 
                                : int.tryParse(studentId?.toString() ?? '');
                            return DropdownMenuItem(
                              value: studentIdInt,
                              child: Text(_getStudentDisplay(student)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStudentId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a student';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Section Dropdown
                      const Text(
                        'Section *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedSectionId,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select a section',
                          ),
                          items: widget.sections.map((section) {
                            final sectionId = section['id'] ?? section['sectionId'];
                            final sectionIdInt = sectionId is int 
                                ? sectionId 
                                : int.tryParse(sectionId?.toString() ?? '');
                            final sectionName = section['name']?.toString() ?? 'Section $sectionId';
                            return DropdownMenuItem(
                              value: sectionIdInt,
                              child: Text(sectionName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSectionId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a section';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Subject Dropdown
                      const Text(
                        'Subject *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedSubjectId,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select a subject',
                          ),
                          items: widget.subjects.map((subject) {
                            final subjectId = subject['id'] ?? subject['subjectId'];
                            final subjectIdInt = subjectId is int 
                                ? subjectId 
                                : int.tryParse(subjectId?.toString() ?? '');
                            final name = subject['name']?.toString() ?? '';
                            final code = subject['code']?.toString() ?? '';
                            final display = name.isNotEmpty && code.isNotEmpty
                                ? '$code - $name'
                                : (name.isNotEmpty ? name : (code.isNotEmpty ? code : 'Subject $subjectId'));
                            return DropdownMenuItem(
                              value: subjectIdInt,
                              child: Text(display),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubjectId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subject';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isEnrolling ? null : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isEnrolling ? null : _handleEnroll,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E3A8A),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isEnrolling
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    )
                                  : const Text(
                                      'Enroll',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

