import 'package:flutter/material.dart';
import '../providers/app_data.dart';
class TeachersManagementScreen extends StatefulWidget {
  const TeachersManagementScreen({super.key});

  @override
  State<TeachersManagementScreen> createState() => _TeachersManagementScreenState();
}

class _TeachersManagementScreenState extends State<TeachersManagementScreen> {
  String? _selectedTeacherToRemove;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All Status';
  final List<String> _statusOptions = ['All Status', 'Active', 'Inactive'];
  
  List<Map<String, String>> get _teachers => AppData.teachers.value;

  List<Map<String, String>> get _filteredTeachers {
    final query = _searchController.text.trim().toLowerCase();
    return _teachers.where((teacher) {
      final matchesQuery = query.isEmpty ||
          teacher['name']!.toLowerCase().contains(query) ||
          teacher['email']!.toLowerCase().contains(query) ||
          teacher['subject']!.toLowerCase().contains(query);
      final matchesStatus = _selectedStatusFilter == 'All Status' || teacher['status'] == _selectedStatusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _showRemoveTeacherDialog(int index) {
    final teacher = _teachers[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Teacher'),
          content: Text('Are you sure you want to remove ${teacher['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final removed = _teachers[index];
                await AppData.deleteByEmail(removed['email']!);
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${teacher['name']} removed successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSelectTeacherDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Teacher'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _teachers.length,
              itemBuilder: (context, index) {
                final teacher = _teachers[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(teacher['name']!),
                  subtitle: Text(teacher['email']!),
                  onTap: () => Navigator.of(context).pop(teacher['name']),
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
        );
      },
    );
    if (selected != null) {
      setState(() {
        _selectedTeacherToRemove = selected;
      });
    }
  }

  void _showAddTeacherDialog() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _subjectController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF7F8FA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', filled: true, border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter teacher name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', filled: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      final email = value.trim().toLowerCase();
                      final allowedDomains = [
                        'gmail.com',
                        'outlook.com',
                        'yahoo.com',
                        'hotmail.com',
                        'aol.com',
                        'icloud.com',
                        'protonmail.com',
                        'yandex.com',
                        'mail.com'
                      ];
                      
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(email)) {
                        return 'Please enter a valid email address.';
                      }
                      
                      final domain = email.split('@')[1];
                      if (!allowedDomains.contains(domain)) {
                        return 'Email must be from an allowed domain (gmail.com, outlook.com, yahoo.com, etc.).';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Subject', filled: true, border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                              AppData.addTeacher({
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'subject': _subjectController.text,
                                'status': 'Active',
                              });
                              setState(() {});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Teacher added successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Teachers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          // Top search + chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF667085)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(hintText: 'Search teachers...', isCollapsed: true, border: InputBorder.none),
                      ),
                    )
                  ]),
                ),
                const SizedBox(height: 8),
                _buildStatusFilter(),
                const SizedBox(height: 8),
                Row(children: [
                  _statChip(Icons.people_alt_rounded, '${_teachers.length} Total'),
                  const SizedBox(width: 8),
                  _statChip(Icons.check_circle_rounded, '${_teachers.where((t) => t['status'] == 'Active').length} Active'),
                ])
              ],
            ),
          ),
          
          // Teachers List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Teachers List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _filteredTeachers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: const Icon(Icons.person_rounded, color: Colors.blue),
                            ),
                            title: Text(
                              teacher['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teacher['email']!),
                                Text(
                                  'Subject: ${teacher['subject']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              onPressed: () => _showTeacherActions(teacher),
                            ),
                            onTap: () => _showTeacherActions(teacher),
                            onLongPress: () {
                              _showRemoveTeacherDialog(index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF344054)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatusFilter,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: _statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
          onChanged: (val) => setState(() => _selectedStatusFilter = val ?? 'All Status'),
        ),
      ),
    );
  }

  void _showTeacherActions(Map<String, String> teacher) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _showRemoveTeacherDialog(_teachers.indexOf(teacher));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

