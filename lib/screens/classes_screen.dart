import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClassesScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const ClassesScreen({super.key, this.onBackPressed});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getClassrooms();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _classrooms = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _classrooms = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load classrooms';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load classrooms: $e';
        _isLoading = false;
      });
    }
  }

  int get _totalClassesCount => _classrooms.length;

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
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _buildContent(),
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
          const SizedBox(width: 12),
          // Classes Title
          const Expanded(
            child: Text(
              'Classes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Add Class Button
          IconButton(
            onPressed: () => _showAddClassroomModal(),
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Classes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadClassrooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classes Overview
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text(
                  'Classes Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Grid
          _buildStatsGrid(),
          
          const SizedBox(height: 24),
          
          // Classes List Section
          const Text(
            'Classes List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Classes Cards
          _buildClassesList(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Total Classes',
          value: _totalClassesCount.toString(),
          progress: _totalClassesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.class_,
        ),
        _buildStatCard(
          title: 'Active Classes',
          value: _totalClassesCount.toString(),
          progress: _totalClassesCount > 0 ? 1.0 : 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.school,
        ),
        _buildStatCard(
          title: 'Total Students',
          value: '0',
          progress: 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.people,
        ),
        _buildStatCard(
          title: 'Total Instructors',
          value: '0',
          progress: 0.0,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required double progress,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    if (_classrooms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No classrooms available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new classroom to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _classrooms.length,
      itemBuilder: (context, index) {
        final classroom = _classrooms[index];
        return _buildClassroomCard(classroom);
      },
    );
  }

  Widget _buildClassroomCard(Map<String, dynamic> classroom) {
    final id = classroom['id']?.toString() ?? 'N/A';
    final name = classroom['name']?.toString() ?? 'Unnamed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Classroom Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.class_,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Classroom Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditClassroomModal(classroom),
                icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(classroom),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddClassroomModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
          child: _AddClassroomModalContent(
            onClassroomCreated: () => _loadClassrooms(),
          ),
        ),
      ),
    );
  }

  void _showEditClassroomModal(Map<String, dynamic> classroom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
          child: _EditClassroomModalContent(
            classroom: classroom,
            onClassroomUpdated: () => _loadClassrooms(),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> classroom) {
    final name = classroom['name']?.toString() ?? 'this classroom';
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Classroom',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "$name"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF667085),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleDeleteClassroom(classroom);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
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
    );
  }

  Future<void> _handleDeleteClassroom(Map<String, dynamic> classroom) async {
    final id = classroom['id'];
    if (id == null) return;

    try {
      final response = await _apiService.deleteClassroom(id as int);
      if (response['success'] == true) {
        if (mounted) {
          _showSuccessModal('Classroom deleted successfully');
          _loadClassrooms();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete classroom'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessModal(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF667085),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Classroom Modal
class _AddClassroomModalContent extends StatefulWidget {
  final VoidCallback? onClassroomCreated;
  
  const _AddClassroomModalContent({this.onClassroomCreated});

  @override
  State<_AddClassroomModalContent> createState() => _AddClassroomModalContentState();
}

class _AddClassroomModalContentState extends State<_AddClassroomModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _fieldErrors = {};
    });

    final response = await _apiService.createClassroom(_nameController.text.trim());

    setState(() {
      _isCreating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onClassroomCreated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors = response['errors'] as Map<String, List<String>>?;
      
      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });
      
      _formKey.currentState?.validate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to create classroom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Classroom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name',
                  hintText: 'Enter classroom name',
                  prefixIcon: const Icon(Icons.class_, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Classroom name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Classroom name must be at least 2 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Classroom name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Create Button
              ElevatedButton(
                onPressed: _isCreating ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Create Classroom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Classroom Modal
class _EditClassroomModalContent extends StatefulWidget {
  final Map<String, dynamic> classroom;
  final VoidCallback? onClassroomUpdated;
  
  const _EditClassroomModalContent({
    required this.classroom,
    this.onClassroomUpdated,
  });

  @override
  State<_EditClassroomModalContent> createState() => _EditClassroomModalContentState();
}

class _EditClassroomModalContentState extends State<_EditClassroomModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final TextEditingController _nameController;
  bool _isUpdating = false;
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classroom['name']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _fieldErrors = {};
    });

    final id = widget.classroom['id'] as int;
    final response = await _apiService.updateClassroom(id, _nameController.text.trim());

    setState(() {
      _isUpdating = false;
    });

    if (response['success'] == true) {
      if (mounted) {
        widget.onClassroomUpdated?.call();
        Navigator.of(context).pop();
      }
    } else {
      Map<String, List<String>>? apiErrors = response['errors'] as Map<String, List<String>>?;
      
      setState(() {
        _fieldErrors = {};
        if (apiErrors != null && apiErrors.containsKey('Name')) {
          _fieldErrors['name'] = apiErrors['Name']!.first;
        }
      });
      
      _formKey.currentState?.validate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to update classroom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Classroom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name',
                  hintText: 'Enter classroom name',
                  prefixIcon: const Icon(Icons.class_, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  errorText: _fieldErrors['name'],
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Classroom name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Classroom name must be at least 2 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Classroom name must be at most 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Update Button
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : const Text(
                        'Update Classroom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
