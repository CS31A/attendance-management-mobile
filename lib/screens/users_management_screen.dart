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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _selectedRoleFilter = 'All Roles';
  
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> get _visibleUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.where((u) {
      final name = _getUserName(u);
      final email = u['email']?.toString().toLowerCase() ?? '';
      final username = u['username']?.toString().toLowerCase() ?? '';
      
      final matchesQuery = query.isEmpty ||
          name.toLowerCase().contains(query) ||
          email.contains(query) ||
          username.contains(query);
      final matchesRole = _selectedRoleFilter == 'All Roles' || 
          (u['role']?.toString() ?? '') == _selectedRoleFilter;
      return matchesQuery && matchesRole;
    }).toList();
  }

  int get _adminCount => _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'admin').length;

  String _getUserName(Map<String, dynamic> user) {
    if (user['firstname'] != null || user['lastname'] != null) {
      final firstname = user['firstname']?.toString() ?? '';
      final lastname = user['lastname']?.toString() ?? '';
      return '$firstname $lastname'.trim();
    }
    return user['name']?.toString() ?? 
           user['username']?.toString() ?? 
           'Unknown User';
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
              _buildHeader(),
              _buildSearchAndFilters(context),
              if (!_isLoading && _errorMessage == null) _buildStatsCards(),
              const SizedBox(height: 8),
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
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadUsers,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _visibleUsers.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'No users found',
                                    style: TextStyle(
                                      color: Color(0xFF667085),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : _visibleUsers.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: _visibleUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = _visibleUsers[index];
                                      return _buildUserTile(user);
                                    },
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _openCreateUser,
            icon: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF667085), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      if (mounted) setState(() {});
                    },
                    style: const TextStyle(color: Color(0xFF1E3A8A)),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                      isCollapsed: true,
                      border: InputBorder.none,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Color(0xFF667085)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              padding: EdgeInsets.zero,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildRoleToggleButtons(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRoleToggleButtons() {
    if (_users.isEmpty) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No users to filter',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    final allCount = _users.length;
    final adminCount = _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'admin').length;
    final teacherCount = _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'teacher').length;
    final studentCount = _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'student').length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Role',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleToggleButton(
                label: 'All',
                icon: Icons.people_outline,
                count: allCount,
                isSelected: _selectedRoleFilter == 'All Roles',
                onTap: () => setState(() => _selectedRoleFilter = 'All Roles'),
                gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              _buildRoleToggleButton(
                label: 'Admins',
                icon: Icons.admin_panel_settings,
                count: adminCount,
                isSelected: _selectedRoleFilter == 'Admin',
                onTap: () => setState(() => _selectedRoleFilter = 'Admin'),
                gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              ),
              _buildRoleToggleButton(
                label: 'Teachers',
                icon: Icons.school,
                count: teacherCount,
                isSelected: _selectedRoleFilter == 'Teacher',
                onTap: () => setState(() => _selectedRoleFilter = 'Teacher'),
                gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
              ),
              _buildRoleToggleButton(
                label: 'Students',
                icon: Icons.person_outline,
                count: studentCount,
                isSelected: _selectedRoleFilter == 'Student',
                onTap: () => setState(() => _selectedRoleFilter = 'Student'),
                gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggleButton({
    required String label,
    required IconData icon,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE4E7EC),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : gradientColors[0],
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final teacherCount = _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'teacher').length;
    final studentCount = _users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'student').length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildGlassStatCard(
              icon: Icons.school,
              value: studentCount.toString(),
              label: 'Students',
              iconColor: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGlassStatCard(
              icon: Icons.person,
              value: teacherCount.toString(),
              label: 'Teacher',
              iconColor: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGlassStatCard(
              icon: Icons.admin_panel_settings,
              value: _adminCount.toString(),
              label: 'Admin',
              iconColor: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No users found',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Get started by adding your first user'
                  : 'Try adjusting your search or filters',
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _searchController.text.isEmpty ? _openCreateUser : () {
                _searchController.clear();
                _selectedRoleFilter = 'All Roles';
                setState(() {});
              },
              icon: Icon(_searchController.text.isEmpty ? Icons.add : Icons.clear),
              label: Text(_searchController.text.isEmpty ? 'Add User' : 'Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? 'N/A';
    final email = user['email']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showUserActionSheet(user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getUserName(user).isNotEmpty ? _getUserName(user)[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserName(user),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _roleColor(role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: _roleColor(role),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E3A8A)),
                    onPressed: () => _showUserActionSheet(user),
                    tooltip: 'More options',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserActionSheet(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _roleColor(user['role']?.toString() ?? 'Admin').withOpacity(0.12),
                    child: Icon(Icons.account_circle_rounded, color: _roleColor(user['role']?.toString() ?? 'Admin')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserName(user),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        Text(
                          user['email']?.toString() ?? 'N/A',
                          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6)),
                title: const Text('Edit user', style: TextStyle(color: Color(0xFF1E3A8A))),
                onTap: () {
                  Navigator.pop(context);
                  _openEditScreen(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete user', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(user);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
              )
            ],
          ),
        );
      },
    );
  }

  void _openEditScreen(Map<String, dynamic> user) {
    final userId = user['id']?.toString() ?? user['userId']?.toString() ?? '';
    String username = user['username']?.toString() ?? '';
    String firstname = user['firstname']?.toString() ?? '';
    String lastname = user['lastname']?.toString() ?? '';
    String email = user['email']?.toString() ?? '';
    String role = user['role']?.toString() ?? 'Teacher';
    String sectionId = user['sectionId']?.toString() ?? '';

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
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Form(
                  key: _editFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Edit User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Username',
                          initialValue: username,
                          onChanged: (v) => username = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter a username.';
                            if (v.trim().length < 3 || v.trim().length > 50) {
                              return 'Username must be between 3 and 50 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'First Name',
                          initialValue: firstname,
                          onChanged: (v) => firstname = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Last Name',
                          initialValue: lastname,
                          onChanged: (v) => lastname = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Email',
                          initialValue: email,
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
                        _sheetDropdown(
                          label: 'Role',
                          value: role,
                          items: const ['Admin', 'Teacher', 'Student'],
                          onChanged: (v) => role = v,
                        ),
                        const SizedBox(height: 12),
                        _sheetTextField(
                          label: 'Section ID',
                          initialValue: sectionId,
                          onChanged: (v) => sectionId = v,
                          hintText: 'Optional',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSaving ? null : () => Navigator.pop(ctx),
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
                                onPressed: isSaving ? null : () async {
                                  if (_editFormKey.currentState!.validate()) {
                                    setModalState(() => isSaving = true);
                                    
                                    final response = await _apiService.updateUser(
                                      userId: userId,
                                      username: username.trim(),
                                      firstname: firstname.trim().isEmpty ? null : firstname.trim(),
                                      lastname: lastname.trim().isEmpty ? null : lastname.trim(),
                                      email: email.trim(),
                                      role: role,
                                      sectionId: sectionId.trim().isEmpty ? null : sectionId.trim(),
                                    );
                                    
                                    setModalState(() => isSaving = false);
                                    
                                    if (response['success'] == true) {
                                      final message = response['message'] ?? 'User updated';
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
                                      final message = response['message'] ?? 'Failed to update user';
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
                                child: isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Save Changes'),
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

  Color _roleColor(String role) {
    switch (role) {
      case 'Teacher':
        return Colors.purple;
      case 'Student':
        return Colors.teal;
      case 'Admin':
      default:
        return Colors.blue;
    }
  }

  void _confirmDelete(Map<String, dynamic> user) {
    final userId = user['id']?.toString() ?? user['userId']?.toString() ?? '';
    final userName = _getUserName(user);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E3A8A))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              final response = await _apiService.deleteUser(userId);
              
              if (response['success'] == true) {
                final message = response['message'] ?? 'User deleted';
                await _loadUsers();
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
              } else {
                final message = response['message'] ?? 'Failed to delete user';
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
            },
            child: const Text('Delete user'),
          ),
        ],
      ),
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
    String? prefixText,
    int? maxLength,
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
          maxLength: maxLength,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            prefixText: prefixText,
            hintText: hintText,
            counterText: '',
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