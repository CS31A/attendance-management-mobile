import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TeachersManagementScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const TeachersManagementScreen({super.key, this.onBackPressed});

  @override
  State<TeachersManagementScreen> createState() => _TeachersManagementScreenState();
}

class _TeachersManagementScreenState extends State<TeachersManagementScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _instructors = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getInstructors();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _instructors = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _instructors = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load instructors';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load instructors: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredInstructors {
    final query = _searchController.text.trim().toLowerCase();
    return _instructors.where((instructor) {
      final matchesQuery = query.isEmpty ||
          (instructor['firstname']?.toString().toLowerCase() ?? '').contains(query) ||
          (instructor['lastname']?.toString().toLowerCase() ?? '').contains(query);
      
      final isDeleted = instructor['isDeleted'] == true;
      final matchesStatus = _selectedStatusFilter == 'All' ||
          (_selectedStatusFilter == 'Active' && !isDeleted) ||
          (_selectedStatusFilter == 'Deleted' && isDeleted);
      
      return matchesQuery && matchesStatus;
    }).toList();
  }

  String _getInstructorName(Map<String, dynamic> instructor) {
    final firstname = instructor['firstname']?.toString() ?? '';
    final lastname = instructor['lastname']?.toString() ?? '';
    if (firstname.isNotEmpty || lastname.isNotEmpty) {
      return '$firstname $lastname'.trim();
    }
    return 'Instructor ${instructor['id']}';
  }

  int get _totalCount => _instructors.length;
  int get _activeCount => _instructors.where((i) => i['isDeleted'] != true).length;
  int get _deletedCount => _instructors.where((i) => i['isDeleted'] == true).length;

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
                                  onPressed: _loadInstructors,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _buildInstructorsList(),
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
          // Back Arrow
          IconButton(
            onPressed: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            tooltip: 'Back',
          ),
          const Expanded(
            child: Text(
              'Teachers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _loadInstructors,
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
                      hintText: 'Search teachers...',
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
                DropdownMenuItem(value: 'All', child: Text('All Teachers')),
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

  Widget _buildInstructorsList() {
    if (_filteredInstructors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No teachers found',
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
                  : 'Teachers will appear here',
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
      itemCount: _filteredInstructors.length,
      itemBuilder: (context, index) {
        final instructor = _filteredInstructors[index];
        return _buildInstructorCard(instructor);
      },
    );
  }

  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    final instructorName = _getInstructorName(instructor);
    final instructorId = instructor['id'];
    final isDeleted = instructor['isDeleted'] == true;
    final userId = instructor['userId'];

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
          // Instructor Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDeleted
                    ? [Colors.grey[400]!, Colors.grey[600]!]
                    : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeleted ? Icons.person_off : Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Instructor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDeleted ? Colors.grey[600] : const Color(0xFF1E3A8A),
                    decoration: isDeleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (userId != null) ...[
                  const SizedBox(height: 4),
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
                  _showEditInstructorDialog(instructor);
                  break;
                case 'soft_delete':
                  _softDeleteInstructor(instructorId);
                  break;
                case 'restore':
                  _restoreInstructor(instructorId);
                  break;
                case 'delete':
                  _deleteInstructor(instructorId);
                  break;
                case 'subjects':
                  _showInstructorSubjects(instructorId);
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
                  value: 'subjects',
                  child: Row(
                    children: [
                      Icon(Icons.subject, size: 18, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('View Subjects'),
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

  void _showEditInstructorDialog(Map<String, dynamic> instructor) {
    final firstnameController = TextEditingController(
      text: instructor['firstname']?.toString() ?? '',
    );
    final lastnameController = TextEditingController(
      text: instructor['lastname']?.toString() ?? '',
    );
    final instructorId = instructor['id'] as int;
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Teacher'),
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

                  final response = await _apiService.updateInstructor(
                    id: instructorId,
                    firstname: firstnameController.text.trim().isEmpty
                        ? null
                        : firstnameController.text.trim(),
                    lastname: lastnameController.text.trim().isEmpty
                        ? null
                        : lastnameController.text.trim(),
                  );

                  setDialogState(() {
                    isUpdating = false;
                  });

                  if (response['success'] == true) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'Teacher updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadInstructors();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Failed to update teacher'),
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

  Future<void> _softDeleteInstructor(int instructorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soft Delete Teacher'),
        content: const Text('Are you sure you want to soft delete this teacher? They can be restored later.'),
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
      final response = await _apiService.softDeleteInstructor(instructorId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Teacher soft deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadInstructors();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to soft delete teacher'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreInstructor(int instructorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Teacher'),
        content: const Text('Are you sure you want to restore this teacher?'),
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
      final response = await _apiService.restoreInstructor(instructorId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Teacher restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadInstructors();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to restore teacher'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteInstructor(int instructorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hard Delete Teacher'),
        content: const Text(
          'Are you sure you want to permanently delete this teacher? This action cannot be undone.',
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
      final response = await _apiService.deleteInstructor(instructorId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Teacher deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadInstructors();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete teacher'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showInstructorSubjects(int instructorId) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final response = await _apiService.getInstructorSubjects(instructorId);
    
    if (!mounted) return;
    Navigator.of(context).pop(); // Close loading dialog

    if (response['success'] == true) {
      final subjects = response['data'] as List<Map<String, dynamic>>;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Instructor Subjects'),
          content: SizedBox(
            width: double.maxFinite,
            child: subjects.isEmpty
                ? const Text('No subjects assigned')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      final name = subject['name']?.toString() ?? 'Unknown';
                      final code = subject['code']?.toString() ?? '';
                      return ListTile(
                        leading: const Icon(Icons.subject),
                        title: Text(name),
                        subtitle: code.isNotEmpty ? Text(code) : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to load subjects'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
