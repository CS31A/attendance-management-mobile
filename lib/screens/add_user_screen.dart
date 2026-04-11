import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

class AddUserScreen extends StatefulWidget {
  final VoidCallback? onUserCreated;

  const AddUserScreen({super.key, this.onUserCreated});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatedPasswordController =
      TextEditingController();
  final TextEditingController _sectionIdController = TextEditingController();

  String role = 'Teacher';
  bool isPasswordVisible = false;
  bool isRepeatedPasswordVisible = false;
  bool isCreating = false;

  // Store API validation errors
  Map<String, String?> fieldErrors = {};

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatedPasswordController.dispose();
    _sectionIdController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isCreating = true;
    });

    final response = await _apiService.registerUser(
      username: _usernameController.text.trim(),
      firstname: _firstnameController.text.trim().isEmpty
          ? null
          : _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim().isEmpty
          ? null
          : _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      repeatedPassword: _repeatedPasswordController.text,
      role: role,
      sectionId: _sectionIdController.text.trim().isEmpty
          ? null
          : _sectionIdController.text.trim(),
    );

    setState(() {
      isCreating = false;
    });

    if (response['success'] == true) {
      // Clear any field errors on success
      setState(() {
        fieldErrors = {};
      });

      final message = response['message'] ?? 'User created successfully';
      if (mounted) {
        widget.onUserCreated?.call();
        Navigator.of(context).pop(); // Close screen
        _showSuccessModal(context, message);
      }
    } else {
      // Handle API validation errors
      Map<String, List<String>>? apiErrors =
          response['errors'] as Map<String, List<String>>?;

      setState(() {
        // Clear previous errors
        fieldErrors = {};

        // Map API field names to form field names and store errors
        if (apiErrors != null) {
          if (apiErrors.containsKey('Username')) {
            fieldErrors['username'] = apiErrors['Username']!.first;
          }
          if (apiErrors.containsKey('Email')) {
            fieldErrors['email'] = apiErrors['Email']!.first;
          }
          if (apiErrors.containsKey('Password')) {
            fieldErrors['password'] = apiErrors['Password']!.first;
          }
          if (apiErrors.containsKey('RepeatedPassword')) {
            fieldErrors['repeatedPassword'] =
                apiErrors['RepeatedPassword']!.first;
          }
        }
      });

      // Trigger form validation to show field errors
      _formKey.currentState?.validate();

      final message = response['message'] ?? 'Failed to create user';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showSuccessModal(BuildContext context, String message) {
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
              // Success Icon
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

              // Success Message
              const Text(
                'User Created Successfully!',
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

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              Container(
                padding: Responsive.paddingHorizontal(context).copyWith(
                  top: Responsive.spacing(context, mobile: 8, tablet: 12, desktop: 16),
                  bottom: Responsive.spacing(context, mobile: 8, tablet: 12, desktop: 16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Add User',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.headingFontSize(context, mobile: 20, tablet: 24, desktop: 28),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, mobile: 40, tablet: 48, desktop: 56)), // Balance back button
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: Responsive.padding(context),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        _buildTextField(
                          label: 'Username',
                          icon: Icons.person_outline,
                          controller: _usernameController,
                          hintText: 'Enter username',
                          isRequired: true,
                          fieldKey: 'username',
                          validator: (v) {
                            if (fieldErrors.containsKey('username')) {
                              return fieldErrors['username'];
                            }
                            if (v == null || v.trim().isEmpty)
                              return 'Username is required.';
                            if (v.trim().length < 3 || v.trim().length > 50) {
                              return 'Username must be between 3 and 50 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // First Name
                        _buildTextField(
                          label: 'First Name',
                          icon: Icons.badge_outlined,
                          controller: _firstnameController,
                          hintText: 'Enter first name',
                        ),
                        const SizedBox(height: 20),

                        // Last Name
                        _buildTextField(
                          label: 'Last Name',
                          icon: Icons.badge_outlined,
                          controller: _lastnameController,
                          hintText: 'Enter last name',
                        ),
                        const SizedBox(height: 20),

                        // Email
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          hintText: 'Enter email address',
                          isRequired: true,
                          keyboardType: TextInputType.emailAddress,
                          fieldKey: 'email',
                          validator: (v) {
                            if (fieldErrors.containsKey('email')) {
                              return fieldErrors['email'];
                            }
                            if (v == null || v.trim().isEmpty)
                              return 'Email is required.';
                            final emailRegex =
                                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Invalid email format.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password
                        _buildPasswordField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          hintText: 'Enter password',
                          isRequired: true,
                          isVisible: isPasswordVisible,
                          onToggleVisibility: () => setState(
                              () => isPasswordVisible = !isPasswordVisible),
                          fieldKey: 'password',
                          validator: (v) {
                            if (fieldErrors.containsKey('password')) {
                              return fieldErrors['password'];
                            }
                            if (v == null || v.trim().isEmpty)
                              return 'Password is required.';
                            if (v.length < 6 || v.length > 100) {
                              return 'Password must be between 6 and 100 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Repeat Password
                        _buildPasswordField(
                          label: 'Repeat Password',
                          icon: Icons.lock_outline,
                          controller: _repeatedPasswordController,
                          hintText: 'Repeat password',
                          isRequired: true,
                          isVisible: isRepeatedPasswordVisible,
                          onToggleVisibility: () => setState(() =>
                              isRepeatedPasswordVisible =
                                  !isRepeatedPasswordVisible),
                          fieldKey: 'repeatedPassword',
                          validator: (v) {
                            if (fieldErrors.containsKey('repeatedPassword')) {
                              return fieldErrors['repeatedPassword'];
                            }
                            if (v == null || v.trim().isEmpty)
                              return 'Repeated password is required.';
                            if (v != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Role
                        _buildDropdown(
                          label: 'Role',
                          icon: Icons.assignment_ind_outlined,
                          value: role,
                          items: const ['Admin', 'Teacher', 'Student'],
                          onChanged: (v) => setState(() => role = v),
                        ),
                        const SizedBox(height: 20),

                        // Section ID (only show for Student role)
                        if (role == 'Student') ...[
                          _buildTextField(
                            label: 'Section ID',
                            icon: Icons.numbers,
                            controller: _sectionIdController,
                            hintText: 'Enter section ID',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                        ],

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isCreating
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                              flex: 2,
                              child: ElevatedButton(
                                onPressed:
                                    isCreating ? null : _handleCreateUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                ),
                                child: isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      )
                                    : const Text(
                                        'Add User',
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3, // Users tab
          onTap: (index) {
            // Since this is a sub-screen of Users, any navigation should probably just go back
            // or we could implement full navigation. For now, let's just pop back.
            Navigator.of(context).pop();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Enrollment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    IconData? icon,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
    String? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: (value) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              setState(() {
                fieldErrors.remove(fieldKey);
              });
              _formKey.currentState?.validate();
            }
          },
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF667085),
                    size: 20,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 16 : 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    IconData? icon,
    required TextEditingController controller,
    bool isRequired = false,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? hintText,
    String? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          onChanged: (value) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              setState(() {
                fieldErrors.remove(fieldKey);
              });
              _formKey.currentState?.validate();
            }
          },
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF667085),
                    size: 20,
                  )
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF667085),
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 16 : 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    IconData? icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => onChanged(v ?? value),
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF667085),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: const Color(0xFF667085),
                    size: 20,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 16 : 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select a role.' : null,
        ),
      ],
    );
  }
}
