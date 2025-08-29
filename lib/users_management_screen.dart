import 'package:flutter/material.dart';
import 'app_data.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  String _selectedFilter = 'All';
  String _selectedRoleFilter = 'All Roles';
  final List<String> _roles = ['All Roles', 'Admin', 'Teacher', 'Student'];

  List<Map<String, dynamic>> get _users => AppData.users.value;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.where((u) {
      final matchesQuery = query.isEmpty ||
          u['name'].toString().toLowerCase().contains(query) ||
          u['email'].toString().toLowerCase().contains(query);
      final matchesRole = _selectedRoleFilter == 'All Roles' || u['role'] == _selectedRoleFilter;
      return matchesQuery && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Users'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _openCreateUser,
            icon: const Icon(Icons.add, size: 22),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _visibleUsers.length,
              itemBuilder: (context, index) {
                final user = _visibleUsers[index];
                return _buildUserTile(user);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF667085), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
                  Row(
                    children: [
              Expanded(child: _buildRoleDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoleFilter,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (val) => setState(() => _selectedRoleFilter = val ?? 'All Roles'),
        ),
      ),
    );
  }

  Widget _buildOutlinedPill({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF344054)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
          backgroundColor: _colorFrom(user['color']).withOpacity(0.12),
          backgroundImage: NetworkImage(_avatarFromName(user['name'])),
          child: Icon(Icons.person, color: _colorFrom(user['color'])),
        ),
        title: Row(
                              children: [
            Expanded(
                                  child: Text(
                user['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
        subtitle: Text(user['role']),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _showUserActionSheet(user),
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
                    backgroundColor: _colorFrom(user['color']).withOpacity(0.12),
                    child: Icon(Icons.account_circle_rounded, color: _colorFrom(user['color'])),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(user['email'], style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit user'),
                onTap: () {
                  Navigator.pop(context);
                  _openEditScreen(user);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete user'),
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
    final Map<String, dynamic> working = Map<String, dynamic>.from(user);
    String name = working['name'];
    String email = working['email'];
    String phone = working['phone'];
    String role = working['role'];

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
                    const Text('Edit User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Name',
                      initialValue: name,
                      onChanged: (v) => name = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a name.';
                        // Letters, spaces and common separators only; disallow digits
                        final valid = RegExp(r"^[A-Za-z .'-]+").hasMatch(v.trim()) && !RegExp(r"\\d").hasMatch(v);
                        return valid ? null : 'Name cannot contain numbers.';
                      },
                    ),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Email',
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => email = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter an email address.';
                        final gmail = RegExp(r'^[^@\s]+@gmail\.com$').hasMatch(v.trim().toLowerCase());
                        if (!gmail) return 'Only Gmail addresses are accepted (example@gmail.com).';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Phone Number',
                      initialValue: phone,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => phone = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a phone number.';
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length != 11) return 'Phone number must be exactly 11 digits.';
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_editFormKey.currentState!.validate()) {
                                setState(() {
                                  user['name'] = name;
                                  user['email'] = email;
                                  user['phone'] = phone;
                                  user['role'] = role;
                                });
                                await AppStorage.save();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User updated'), backgroundColor: Colors.green),
                                );
                              }
                            },
                            child: const Text('Save Changes'),
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
  }

  void _openCreateUser() {
    String name = '';
    String email = '';
    String phone = '';
    String role = 'Teacher';

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
                    const Text('Add User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Name',
                      initialValue: '',
                      onChanged: (v) => name = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a name.';
                        final valid = RegExp(r"^[A-Za-z .'-]+$").hasMatch(v.trim());
                        return valid ? null : 'Name cannot contain numbers.';
                      },
                    ),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Email',
                      initialValue: '',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => email = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter an email address.';
                        final gmail = RegExp(r'^[^@\s]+@gmail\.com$').hasMatch(v.trim().toLowerCase());
                        return gmail ? null : 'Only Gmail addresses are accepted (example@gmail.com).';
                      },
                    ),
                    const SizedBox(height: 12),
                    _sheetTextField(
                      label: 'Phone Number',
                      initialValue: '',
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => phone = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a phone number.';
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length != 11) return 'Phone number must be exactly 11 digits.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _sheetDropdown(
                      label: 'Role',
                      value: role,
                      items: const ['Teacher', 'Student', 'Admin'],
                      onChanged: (v) => role = v,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_createFormKey.currentState!.validate()) {
                                final color = _roleColor(role);
                                // Add to Users store
                                final newUsers = List<Map<String, dynamic>>.from(AppData.users.value)
                                  ..add({'name': name, 'email': email, 'role': role, 'status': 'Active', 'phone': phone, 'color': color.value});
                                AppData.users.value = newUsers;

                                // Add to role-specific store
                                if (role == 'Teacher') {
                                  await AppData.addTeacher({'name': name, 'email': email, 'subject': 'N/A', 'status': 'Active'});
                                } else if (role == 'Student') {
                                  await AppData.addStudent({'name': name, 'email': email, 'grade': 'Grade', 'status': 'Active'});
                                }

                                setState(() {});
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User added'), backgroundColor: Colors.green),
                                );
                              }
                            },
                            child: const Text('Add User'),
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

  Color _colorFrom(dynamic value) {
    if (value is Color) return value;
    if (value is int) return Color(value);
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed != null ? Color(parsed) : Colors.blue;
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
          actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
              await AppData.deleteByEmail(user['email']);
              setState(() {});
              Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete user'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow({
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Please select a ${label.toLowerCase()}.' : null,
        ),
      ],
    );
  }

  // Bottom-sheet styled field and dropdown to match the screenshot
  Widget _sheetTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
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

  String _avatarFromName(String name) {
    final seed = name.hashCode % 10;
    // Use DiceBear avatars for quick placeholders
    return 'https://api.dicebear.com/7.x/initials/png?seed=$seed&backgroundType=gradientLinear&fontFamily=Inter&chars=2';
  }

}

class _EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onSave;
  const _EditUserScreen({required this.user, required this.onSave});

  @override
  State<_EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<_EditUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String phone;
  late String role;

  @override
  void initState() {
    super.initState();
    name = widget.user['name'];
    email = widget.user['email'];
    phone = widget.user['phone'];
    role = widget.user['role'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6F8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _labeledField(
                label: 'Name',
                initialValue: name,
                onChanged: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a name.' : null,
              ),
              const SizedBox(height: 12),
              _labeledField(
                label: 'Email',
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => email = v,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter an email address.';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                  return ok ? null : 'Please enter a valid email address.';
                },
              ),
              const SizedBox(height: 12),
              _labeledField(
                label: 'Phone Number',
                initialValue: phone,
                keyboardType: TextInputType.phone,
                onChanged: (v) => phone = v,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a phone number.' : null,
              ),
              const SizedBox(height: 12),
              _dropdownRow(
                label: 'Role',
                value: role,
                items: const ['Admin', 'Teacher', 'Student'],
                onChanged: (v) => role = v,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'name': name,
                            'email': email,
                            'phone': phone,
                            'role': role,
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ValueChanged<String> onChanged,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _dropdownRow({
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Please select a ${label.toLowerCase()}.' : null,
        ),
      ],
    );
  }
}

