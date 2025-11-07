import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentsManagementScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const StudentsManagementScreen({super.key, this.onBackPressed});

  @override
  State<StudentsManagementScreen> createState() => _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getStudents();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _students = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _students = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load students';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    return _students.where((student) {
      final matchesQuery = query.isEmpty ||
          (student['firstname']?.toString().toLowerCase() ?? '').contains(query) ||
          (student['lastname']?.toString().toLowerCase() ?? '').contains(query) ||
          (student['email']?.toString().toLowerCase() ?? '').contains(query);
      
      final isDeleted = student['isDeleted'] == true;
      final matchesStatus = _selectedStatusFilter == 'All' ||
          (_selectedStatusFilter == 'Active' && !isDeleted) ||
          (_selectedStatusFilter == 'Deleted' && isDeleted);
      
      return matchesQuery && matchesStatus;
    }).toList();
  }

  String _getStudentName(Map<String, dynamic> student) {
    final firstname = student['firstname']?.toString() ?? '';
    final lastname = student['lastname']?.toString() ?? '';
    if (firstname.isNotEmpty || lastname.isNotEmpty) {
      return '$firstname $lastname'.trim();
    }
    return 'Student ${student['id']}';
  }

  int get _totalCount => _students.length;
  int get _activeCount => _students.where((s) => s['isDeleted'] != true).length;
  int get _deletedCount => _students.where((s) => s['isDeleted'] == true).length;

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
              
              // Search and Filter
              if (!_isLoading && _errorMessage == null)
                _buildSearchAndFilter(),
              
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
                                  onPressed: _loadStudents,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _buildStudentsList(),
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
              'Students',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search students...',
                      hintStyle: TextStyle(color: Colors.white70),
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedStatusFilter,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1E3A8A),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Students')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Deleted', child: Text('Deleted')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatusFilter = value ?? 'All';
                });
              },
              icon: const Icon(Icons.filter_list, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  Icons.people,
                  '$_totalCount Total',
                  Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  Icons.check_circle,
                  '$_activeCount Active',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  Icons.delete_outline,
                  '$_deletedCount Deleted',
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Students will appear here',
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
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final studentName = _getStudentName(student);
    final studentId = student['id'];
    final isDeleted = student['isDeleted'] == true;
    final isRegular = student['isRegular'] == true;
    final sectionId = student['sectionId'];
    final userId = student['userId'];

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
              gradient: LinearGradient(
                colors: isDeleted
                    ? [Colors.grey[400]!, Colors.grey[600]!]
                    : [const Color(0xFF10B981), const Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeleted ? Icons.person_off : Icons.school,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDeleted ? Colors.grey[600] : const Color(0xFF1E3A8A),
                          decoration: isDeleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (isRegular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Regular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (sectionId != null)
                  Row(
                    children: [
                      Icon(Icons.class_, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Section: $sectionId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                if (userId != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'User ID: $userId',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditStudentDialog(student);
                  break;
                case 'soft_delete':
                  _softDeleteStudent(studentId);
                  break;
                case 'restore':
                  _restoreStudent(studentId);
                  break;
                case 'delete':
                  _deleteStudent(studentId);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!isDeleted) ...[
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'soft_delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Soft Delete'),
                    ],
                  ),
                ),
              ],
              if (isDeleted)
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore, size: 18, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Restore'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hard Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final firstnameController = TextEditingController(
      text: student['firstname']?.toString() ?? '',
    );
    final lastnameController = TextEditingController(
      text: student['lastname']?.toString() ?? '',
    );
    bool isRegular = student['isRegular'] ?? false;
    final studentId = student['id'] as int;
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Student'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return 'First name must be 100 characters or less';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return 'Last name must be 100 characters or less';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Regular Student'),
                    value: isRegular,
                    onChanged: (value) {
                      setDialogState(() {
                        isRegular = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() {
                    isUpdating = true;
                  });

                  final response = await _apiService.updateStudent(
                    id: studentId,
                    firstname: firstnameController.text.trim().isEmpty
                        ? null
                        : firstnameController.text.trim(),
                    lastname: lastnameController.text.trim().isEmpty
                        ? null
                        : lastnameController.text.trim(),
                    isRegular: isRegular,
                  );

                  setDialogState(() {
                    isUpdating = false;
                  });

                  if (response['success'] == true) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'Student updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadStudents();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Failed to update student'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _softDeleteStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soft Delete Student'),
        content: const Text('Are you sure you want to soft delete this student? They can be restored later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Soft Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _apiService.softDeleteStudent(studentId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Student soft deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to soft delete student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Student'),
        content: const Text('Are you sure you want to restore this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _apiService.restoreStudent(studentId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Student restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to restore student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hard Delete Student'),
        content: const Text(
          'Are you sure you want to permanently delete this student? This action cannot be undone.',
        ),
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
      final response = await _apiService.deleteStudent(studentId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
