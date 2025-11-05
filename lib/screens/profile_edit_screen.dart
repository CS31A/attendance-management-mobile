import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;
  
  const ProfileEditScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _isLoadingInitial = true;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // API field error mapping
  Map<String, String?> fieldErrors = {};

  String? _username;
  String? _role;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with provided user, then hydrate from API
    final name = widget.user.name;
    final parts = name.trim().split(' ');
    _firstnameController = TextEditingController(text: parts.isNotEmpty ? parts.first : '');
    _lastnameController = TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _emailController = TextEditingController(text: widget.user.email);

    _loadCurrentAccount();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final response = await _apiService.updateProfile(
      firstname: _firstnameController.text.trim().isEmpty ? null : _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim().isEmpty ? null : _lastnameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      currentPassword: _currentPasswordController.text.isEmpty ? null : _currentPasswordController.text,
      newPassword: _newPasswordController.text.isEmpty ? null : _newPasswordController.text,
      confirmNewPassword: _confirmNewPasswordController.text.isEmpty ? null : _confirmNewPasswordController.text,
    );

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    if (response['success'] == true) {
      // Clear field-specific errors
      setState(() => fieldErrors = {});

      _showSuccessModal(context, response['message'] ?? 'Profile updated successfully');

      // Optionally pop with updated user info if needed
      final updatedProfile = response['updatedProfile'] as Map<String, dynamic>?;
      if (updatedProfile != null) {
        final updatedUser = widget.user.copyWith(
          name: '${updatedProfile['firstname'] ?? _firstnameController.text} ${updatedProfile['lastname'] ?? _lastnameController.text}'.trim(),
          email: updatedProfile['email'] ?? _emailController.text,
        );
        Navigator.pop(context, updatedUser);
      }
    } else {
      // Map API validation errors if provided
      final Map<String, List<String>>? apiErrors = response['errors'] as Map<String, List<String>>?;
      setState(() {
        fieldErrors = {};
        if (apiErrors != null) {
          if (apiErrors.containsKey('Email')) fieldErrors['email'] = apiErrors['Email']!.first;
          if (apiErrors.containsKey('Firstname')) fieldErrors['firstname'] = apiErrors['Firstname']!.first;
          if (apiErrors.containsKey('Lastname')) fieldErrors['lastname'] = apiErrors['Lastname']!.first;
          if (apiErrors.containsKey('CurrentPassword')) fieldErrors['currentPassword'] = apiErrors['CurrentPassword']!.first;
          if (apiErrors.containsKey('NewPassword')) fieldErrors['newPassword'] = apiErrors['NewPassword']!.first;
          if (apiErrors.containsKey('ConfirmNewPassword')) fieldErrors['confirmNewPassword'] = apiErrors['ConfirmNewPassword']!.first;
        }
      });
      _formKey.currentState?.validate();

      final message = response['message'] ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadCurrentAccount() async {
    final result = await _apiService.getCurrentAccount();
    if (!mounted) return;
    if (result['success'] == true && result['data'] is Map<String, dynamic>) {
      final data = result['data'] as Map<String, dynamic>;
      setState(() {
        _username = data['username']?.toString();
        _role = data['role']?.toString();
        final email = data['email']?.toString();
        if (email != null && email.isNotEmpty) {
          _emailController.text = email;
        }
        _isLoadingInitial = false;
      });
    } else {
      setState(() {
        _isLoadingInitial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoadingInitial)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _username ?? widget.user.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        if (_role != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _role!,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(
                    label: 'First Name',
                    icon: Icons.badge_outlined,
                    controller: _firstnameController,
                    fieldKey: 'firstname',
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'Last Name',
                    icon: Icons.badge_outlined,
                    controller: _lastnameController,
                    fieldKey: 'lastname',
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    fieldKey: 'email',
                    validator: (v) {
                      if (fieldErrors.containsKey('email')) return fieldErrors['email'];
                      if (v == null || v.trim().isEmpty) return 'Email is required.';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    label: 'Current Password',
                    icon: Icons.lock_outline,
                    controller: _currentPasswordController,
                    isVisible: _isCurrentPasswordVisible,
                    onToggleVisibility: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                    fieldKey: 'currentPassword',
                    validator: (v) {
                      if (fieldErrors.containsKey('currentPassword')) return fieldErrors['currentPassword'];
                      return null; // optional
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    label: 'New Password',
                    icon: Icons.lock_outline,
                    controller: _newPasswordController,
                    isVisible: _isNewPasswordVisible,
                    onToggleVisibility: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                    fieldKey: 'newPassword',
                    validator: (v) {
                      if (fieldErrors.containsKey('newPassword')) return fieldErrors['newPassword'];
                      if (v != null && v.isNotEmpty && v.length < 6) return 'Minimum 6 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    label: 'Confirm New Password',
                    icon: Icons.lock_outline,
                    controller: _confirmNewPasswordController,
                    isVisible: _isConfirmPasswordVisible,
                    onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    fieldKey: 'confirmNewPassword',
                    validator: (v) {
                      if (fieldErrors.containsKey('confirmNewPassword')) return fieldErrors['confirmNewPassword'];
                      if (_newPasswordController.text.isNotEmpty && v != _newPasswordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1E3A8A)))
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    String? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              return fieldErrors[fieldKey];
            }
            return validator?.call(v);
          },
          onChanged: (value) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              setState(() => fieldErrors.remove(fieldKey));
              _formKey.currentState?.validate();
            }
          },
          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF667085), size: 20) : null,
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 16 : 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
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
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: (v) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              return fieldErrors[fieldKey];
            }
            return validator?.call(v);
          },
          onChanged: (value) {
            if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
              setState(() => fieldErrors.remove(fieldKey));
              _formKey.currentState?.validate();
            }
          },
          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF667085), size: 20) : null,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF667085), size: 22),
              onPressed: onToggleVisibility,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 16 : 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Updated!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}