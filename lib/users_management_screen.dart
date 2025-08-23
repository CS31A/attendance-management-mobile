import 'package:flutter/material.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final List<Map<String, dynamic>> _allUsers = [
    {
      'name': 'John Smith',
      'email': 'john.smith@school.edu',
      'role': 'Teacher',
      'subject': 'Mathematics',
      'status': 'Active',
      'type': 'teacher',
    },
    {
      'name': 'Sarah Johnson',
      'email': 'sarah.johnson@school.edu',
      'role': 'Teacher',
      'subject': 'English',
      'status': 'Active',
      'type': 'teacher',
    },
    {
      'name': 'Emma Wilson',
      'email': 'emma.wilson@student.edu',
      'role': 'Student',
      'grade': 'Grade 10',
      'status': 'Active',
      'type': 'student',
    },
    {
      'name': 'David Lee',
      'email': 'david.lee@student.edu',
      'role': 'Student',
      'grade': 'Grade 11',
      'status': 'Active',
      'type': 'student',
    },
    {
      'name': 'Michael Brown',
      'email': 'michael.brown@school.edu',
      'role': 'Teacher',
      'subject': 'Science',
      'status': 'Active',
      'type': 'teacher',
    },
    {
      'name': 'Lisa Chen',
      'email': 'lisa.chen@student.edu',
      'role': 'Student',
      'grade': 'Grade 9',
      'status': 'Active',
      'type': 'student',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Teachers', 'Students'];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_selectedFilter == 'All') {
      return _allUsers;
    } else if (_selectedFilter == 'Teachers') {
      return _allUsers.where((user) => user['type'] == 'teacher').toList();
    } else {
      return _allUsers.where((user) => user['type'] == 'student').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    _allUsers.length.toString(),
                    Icons.people,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Active Users',
                    _allUsers.where((u) => u['status'] == 'Active').length.toString(),
                    Icons.check_circle,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Teachers',
                    _allUsers.where((u) => u['type'] == 'teacher').length.toString(),
                    Icons.person,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'Students',
                    _allUsers.where((u) => u['type'] == 'student').length.toString(),
                    Icons.school,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter and Users List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Section
                  Row(
                    children: [
                      const Text(
                        'Filter by:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ...(_filterOptions.map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          selectedColor: Colors.orange.withOpacity(0.2),
                          checkmarkColor: Colors.orange,
                        ),
                      ))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Users List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedFilter} Users (${_filteredUsers.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show add user dialog
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Users List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user['type'] == 'teacher' 
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              child: Icon(
                                user['type'] == 'teacher' ? Icons.person : Icons.school,
                                color: user['type'] == 'teacher' ? Colors.blue : Colors.green,
                              ),
                            ),
                            title: Text(
                              user['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email']!),
                                Text(
                                  user['type'] == 'teacher' 
                                      ? 'Subject: ${user['subject']}'
                                      : 'Grade: ${user['grade']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user['type'] == 'teacher'
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user['role']!,
                                    style: TextStyle(
                                      color: user['type'] == 'teacher'
                                          ? Colors.blue
                                          : Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user['status'] == 'Active'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user['status']!,
                                style: TextStyle(
                                  color: user['status'] == 'Active'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            onTap: () {
                              // Show user details or edit
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

