import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersManagementScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const UsersManagementScreen({super.key, this.onBackPressed});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getUsers();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            _users = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _users = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  int get _totalUsersCount => _users.length;
  int get _studentsCount => _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'student').length;
  int get _teachersCount => _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'teacher').length;
  int get _adminsCount => _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'admin').length;

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
                                  onPressed: _loadUsers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Total Users Section
                                const SizedBox(height: 16),
                                const Text(
                                  'Total Users',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_totalUsersCount Users',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Graph Placeholder
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'GRAPH',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Users List Section
                                const Text(
                                  'Users List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Three Cards Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildUserCategoryCard(
                                        label: 'Students',
                                        count: _studentsCount,
                                        icon: Icons.school,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildUserCategoryCard(
                                        label: 'Teacher',
                                        count: _teachersCount,
                                        icon: Icons.person,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildUserCategoryCard(
                                        label: 'Admin',
                                        count: _adminsCount,
                                        icon: Icons.person_outline,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const Expanded(
            child: Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _openCreateUser,
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCategoryCard({
    required String label,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateUser() {
    String username = '';
    String firstname = '';
    String lastname = '';
    String email = '';
    String password = '';
    String repeatedPassword = '';
    String role = 'Teacher';
    String sectionId = '';
    bool isPasswordVisible = false;
    bool isRepeatedPasswordVisible = false;
    final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF7F8FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        bool isCreating = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Form(
                  key: _createFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Username *',
                          initialValue: '',
                          onChanged: (v) => username = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Username is required.';
                            if (v.trim().length < 3 || v.trim().length > 50) {
                              return 'Username must be between 3 and 50 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'First Name',
                          initialValue: '',
                          onChanged: (v) => firstname = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Last Name',
                          initialValue: '',
                          onChanged: (v) => lastname = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Email *',
                          initialValue: '',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) => email = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required.';
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Invalid email format.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _sheetPasswordField(
                          label: 'Password *',
                          initialValue: '',
                          onChanged: (v) => password = v,
                          isVisible: isPasswordVisible,
                          onToggleVisibility: () => setModalState(() => isPasswordVisible = !isPasswordVisible),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Password is required.';
                            if (v.length < 6 || v.length > 100) {
                              return 'Password must be between 6 and 100 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _sheetPasswordField(
                          label: 'Repeat Password *',
                          initialValue: '',
                          onChanged: (v) => repeatedPassword = v,
                          isVisible: isRepeatedPasswordVisible,
                          onToggleVisibility: () => setModalState(() => isRepeatedPasswordVisible = !isRepeatedPasswordVisible),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Repeated password is required.';
                            if (v != password) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _sheetDropdown(
                          label: 'Role',
                          value: role,
                          items: const ['Admin', 'Teacher', 'Student'],
                          onChanged: (v) => role = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Section ID',
                          initialValue: '',
                          onChanged: (v) => sectionId = v,
                          hintText: 'Optional',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isCreating ? null : () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isCreating ? null : () async {
                                  if (_createFormKey.currentState!.validate()) {
                                    setModalState(() => isCreating = true);
                                    
                                    final response = await _apiService.registerUser(
                                      username: username.trim(),
                                      firstname: firstname.trim().isEmpty ? null : firstname.trim(),
                                      lastname: lastname.trim().isEmpty ? null : lastname.trim(),
                                      email: email.trim(),
                                      password: password,
                                      repeatedPassword: repeatedPassword,
                                      role: role,
                                      sectionId: sectionId.trim().isEmpty ? null : sectionId.trim(),
                                    );
                                    
                                    setModalState(() => isCreating = false);
                                    
                                    if (response['success'] == true) {
                                      final message = response['message'] ?? 'User created successfully';
                                      Navigator.pop(ctx);
                                      await _loadUsers();
                                      if (mounted) {
                                        try {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(message),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          // Context no longer valid, ignore
                                        }
                                      }
                                    } else {
                                      final message = response['message'] ?? 'Failed to create user';
                                      if (mounted) {
                                        try {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(message),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } catch (e) {
                                          // Context no longer valid, ignore
                                        }
                                      }
                                    }
                                  }
                                },
                                child: isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Add User'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetPasswordField({
    required String label,
    required String initialValue,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          obscureText: !isVisible,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF98A2B3)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sheetTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF98A2B3)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sheetDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChanged(v ?? value),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF98A2B3)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Please select a role.' : null,
        ),
      ],
    );
  }
}
