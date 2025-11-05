import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
                // Edit profile action
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
        
        // Role badge
        Positioned(
          top: 210,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
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
}