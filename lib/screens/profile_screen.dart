import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/app_data.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await _apiService.getCurrentAccount();
    if (!mounted) return;

    if (res['success'] == true && res['data'] is Map<String, dynamic>) {
      setState(() {
        _account = Map<String, dynamic>.from(res['data'] as Map<String, dynamic>);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = res['message']?.toString() ?? 'Failed to load account';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
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
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
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

    if (shouldLogout != true) return;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call logout API
      final response = await _apiService.logout();

      // Clear tokens and login status regardless of API response
      await StorageService.clearTokens();
      await AppStorage.setLoggedIn(false);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (response['success'] == true) {
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Even if API fails, we still logout locally
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Logged out locally'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Clear tokens and logout locally even if there's an error
      await StorageService.clearTokens();
      await AppStorage.setLoggedIn(false);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out locally'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty || timestamp == '-') return '-';
    try {
      final dt = DateTime.parse(timestamp);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[dt.month - 1];
      final day = dt.day.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$month $day, $year at $hour:$minute';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAccount,
            color: Colors.white,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          _buildErrorState(_error!),
        ],
      );
    }

    final username = _account?['username']?.toString() ?? '-';
    final role = _account?['role']?.toString() ?? '-';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Header with cover and centered profile
        _buildProfileHeader(username: username, role: role),
        
        const SizedBox(height: 20),
        
        // Username
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Edit Profile Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showEditProfileModal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Details Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Details Cards - Dynamically generated from API response
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildDynamicDetails(),
        ),
        
        const SizedBox(height: 40),
        
        // Logout Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProfileHeader({
    required String username,
    required String role,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo Area
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2563EB),
                const Color(0xFF3B82F6).withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Logo in top left
              Positioned(
                top: 16,
                left: 16,
                child: SizedBox(
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
              ),
            ],
          ),
        ),
        
        // Profile Picture - Centered and overlapping
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              children: [
                // Profile circle with black border
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3B82F6),
                          const Color(0xFF1E40AF),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicDetails() {
    if (_account == null) {
      return const SizedBox.shrink();
    }

    // Map of field keys to display configuration
    final fieldConfig = {
      'username': {'icon': Icons.person_outline, 'color': const Color(0xFF3B82F6), 'label': 'Username'},
      'email': {'icon': Icons.email_outlined, 'color': const Color(0xFF3B82F6), 'label': 'Email'},
      'role': {'icon': Icons.admin_panel_settings_outlined, 'color': const Color(0xFF8B5CF6), 'label': 'Role'},
      'firstname': {'icon': Icons.badge_outlined, 'color': const Color(0xFF10B981), 'label': 'First Name'},
      'lastname': {'icon': Icons.badge_outlined, 'color': const Color(0xFF10B981), 'label': 'Last Name'},
      'sectionId': {'icon': Icons.numbers, 'color': const Color(0xFFF59E0B), 'label': 'Section ID'},
      'createdAt': {'icon': Icons.event_outlined, 'color': const Color(0xFF10B981), 'label': 'Joined'},
      'updatedAt': {'icon': Icons.update_outlined, 'color': const Color(0xFFF59E0B), 'label': 'Last Updated'},
      'isRegular': {'icon': Icons.check_circle_outline, 'color': const Color(0xFF10B981), 'label': 'Regular'},
    };

    // Get all fields from account, excluding null/empty values and userId
    final fields = <String, dynamic>{};
    final excludedFields = {'id', 'userId', 'user_id', '_id'};
    _account!.forEach((key, value) {
      if (!excludedFields.contains(key) && 
          value != null && 
          value.toString().isNotEmpty && 
          value.toString() != 'null') {
        fields[key] = value;
      }
    });

    // Build detail cards for each field
    final detailCards = <Widget>[];
    final colorList = [
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];
    int colorIndex = 0;

    fields.forEach((key, value) {
      final config = fieldConfig[key];
      final icon = config?['icon'] as IconData? ?? Icons.info_outline;
      final color = config?['color'] as Color? ?? colorList[colorIndex % colorList.length];
      final label = config?['label'] as String? ?? _formatFieldLabel(key);
      
      String displayValue = value.toString();
      
      // Format timestamps
      if (key == 'createdAt' || key == 'updatedAt') {
        displayValue = _formatTimestamp(displayValue);
      }
      // Format boolean values
      else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      }

      // Add spacing before each card except the first one
      if (detailCards.isNotEmpty) {
        detailCards.add(const SizedBox(height: 12));
      }

      detailCards.add(
        _buildDetailCard(
          icon: icon,
          iconColor: color,
          label: label,
          value: displayValue,
        ),
      );
      colorIndex++;
    });

    if (detailCards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No details available',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(children: detailCards);
  }

  String _formatFieldLabel(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
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
            Icons.error_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Unable to Load Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _loadAccount,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E40AF),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
          child: _EditProfileModalContent(
            account: _account,
            onProfileUpdated: () {
              _loadAccount(); // Reload profile after update
            },
          ),
        ),
      ),
    );
  }
}

class _EditProfileModalContent extends StatefulWidget {
  final Map<String, dynamic>? account;
  final VoidCallback? onProfileUpdated;

  const _EditProfileModalContent({
    this.account,
    this.onProfileUpdated,
  });

  @override
  State<_EditProfileModalContent> createState() => _EditProfileModalContentState();
}

class _EditProfileModalContentState extends State<_EditProfileModalContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _sectionIdController = TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isUpdating = false;
  bool? isRegular;
  Map<String, String?> fieldErrors = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill form with current account data
    if (widget.account != null) {
      _firstnameController.text = widget.account!['firstname']?.toString() ?? '';
      _lastnameController.text = widget.account!['lastname']?.toString() ?? '';
      _emailController.text = widget.account!['email']?.toString() ?? '';
      _sectionIdController.text = widget.account!['sectionId']?.toString() ?? '';
      isRegular = widget.account!['isRegular'] as bool?;
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _sectionIdController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
      fieldErrors = {};
    });

    final response = await _apiService.updateProfile(
      firstname: _firstnameController.text.trim().isEmpty ? null : _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim().isEmpty ? null : _lastnameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      currentPassword: null,
      newPassword: null,
      confirmNewPassword: null,
      sectionId: _sectionIdController.text.trim().isEmpty ? null : _sectionIdController.text.trim(),
      isRegular: isRegular,
    );

    setState(() {
      isUpdating = false;
    });

    if (response['success'] == true) {
      setState(() {
        fieldErrors = {};
      });

      final message = response['message'] ?? 'Profile updated successfully';
      if (mounted) {
        widget.onProfileUpdated?.call();
        Navigator.of(context).pop();
        _showSuccessSnackBar(message);
      }
    } else {
      // Handle API validation errors
      Map<String, List<String>>? apiErrors = response['errors'] as Map<String, List<String>>?;

      setState(() {
        fieldErrors = {};

        if (apiErrors != null) {
          apiErrors.forEach((key, value) {
            // Map API field names to form field names
            String fieldKey = key.toLowerCase();
            if (fieldKey.contains('firstname')) fieldKey = 'firstname';
            else if (fieldKey.contains('lastname')) fieldKey = 'lastname';
            else if (fieldKey.contains('email')) fieldKey = 'email';
            else if (fieldKey.contains('currentpassword')) fieldKey = 'currentPassword';
            else if (fieldKey.contains('newpassword')) fieldKey = 'newPassword';
            else if (fieldKey.contains('confirmpassword')) fieldKey = 'confirmPassword';
            else if (fieldKey.contains('sectionid')) fieldKey = 'sectionId';

            if (value.isNotEmpty) {
              fieldErrors[fieldKey] = value.first;
            }
          });
        }
      });

      _formKey.currentState?.validate();

      final message = response['message'] ?? 'Failed to update profile';
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Column(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Form Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name
                    _buildTextField(
                      label: 'First Name',
                      icon: Icons.badge_outlined,
                      controller: _firstnameController,
                      hintText: 'Enter first name',
                      fieldKey: 'firstname',
                    ),
                    const SizedBox(height: 20),

                    // Last Name
                    _buildTextField(
                      label: 'Last Name',
                      icon: Icons.badge_outlined,
                      controller: _lastnameController,
                      hintText: 'Enter last name',
                      fieldKey: 'lastname',
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      hintText: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                      fieldKey: 'email',
                      validator: (v) {
                        if (fieldErrors.containsKey('email')) {
                          return fieldErrors['email'];
                        }
                        if (v != null && v.trim().isNotEmpty) {
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Invalid email format.';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section ID
                    if (widget.account?['role']?.toString().toLowerCase() == 'student') ...[
                      _buildTextField(
                        label: 'Section ID',
                        icon: Icons.numbers,
                        controller: _sectionIdController,
                        hintText: 'Enter section ID',
                        keyboardType: TextInputType.number,
                        fieldKey: 'sectionId',
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Is Regular (for students)
                    if (widget.account?['role']?.toString().toLowerCase() == 'student') ...[
                      _buildRegularToggle(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottom > 0 ? 0 : 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                    onPressed: isUpdating ? null : _handleUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF1E3A8A),
                            ),
                          )
                        : const Text(
                            'Save Changes',
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
        ],
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
          validator: validator ??
              (v) {
                if (fieldKey != null && fieldErrors.containsKey(fieldKey)) {
                  return fieldErrors[fieldKey];
                }
                return null;
              },
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

  Widget _buildRegularToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Regular Student',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SwitchListTile(
            value: isRegular ?? false,
            onChanged: (value) {
              setState(() {
                isRegular = value;
              });
            },
            activeColor: const Color(0xFF3B82F6),
            title: const Text(
              'Regular Student',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
      ],
    );
  }
}