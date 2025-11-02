import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'filtered_users_screen.dart';

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
              
              // Total Users - Upper Left
              if (!_isLoading && _errorMessage == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ],
                  ),
                ),
              
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
                        : Column(
                            children: [
                              // Scrollable content area with graph
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: _loadUsers,
                                  color: Colors.white,
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Graph Section
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.1),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Graph Header
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        'User Growth',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '$_totalUsersCount Total',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              // Chart
                                              SizedBox(
                                                height: 220,
                                                child: _buildAreaChart(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Bottom section with cards
                              Container(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                          child: GestureDetector(
                                            onTap: () => _navigateToFilteredUsers('Student'),
                                            child: _buildUserCategoryCard(
                                              label: 'Students',
                                              count: _studentsCount,
                                              icon: Icons.school,
                                              gradientColors: [
                                                const Color(0xFF10B981),
                                                const Color(0xFF34D399),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _navigateToFilteredUsers('Teacher'),
                                            child: _buildUserCategoryCard(
                                              label: 'Teacher',
                                              count: _teachersCount,
                                              icon: Icons.person,
                                              gradientColors: [
                                                const Color(0xFF3B82F6),
                                                const Color(0xFF60A5FA),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _navigateToFilteredUsers('Admin'),
                                            child: _buildUserCategoryCard(
                                              label: 'Admin',
                                              count: _adminsCount,
                                              icon: Icons.admin_panel_settings,
                                              gradientColors: [
                                                const Color(0xFF8B5CF6),
                                                const Color(0xFFA78BFA),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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

  void _navigateToFilteredUsers(String role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilteredUsersScreen(
          users: _users,
          role: role,
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

  Widget _buildAreaChart() {
    // Get real-time data based on when accounts were created
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Parse creation dates and group by month
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Initialize month counts for students and teachers
    final List<int> studentCountsByMonth = List.filled(12, 0);
    final List<int> teacherCountsByMonth = List.filled(12, 0);
    
    // Process each user and count by creation month
    for (var user in _users) {
      try {
        final createdAtStr = user['createdAt']?.toString();
        if (createdAtStr != null && createdAtStr.isNotEmpty) {
          // Parse the date (handle ISO 8601 format)
          DateTime? createdAt;
          try {
            createdAt = DateTime.parse(createdAtStr);
          } catch (e) {
            // Try alternative formats if needed
            print('⚠️ Could not parse date: $createdAtStr');
            continue;
          }
          
          // Only count users from current year
          if (createdAt.year == currentYear) {
            final month = createdAt.month - 1; // 0-11 index
            if (month >= 0 && month < 12) {
              final role = user['role']?.toString().toLowerCase() ?? '';
              if (role == 'student') {
                studentCountsByMonth[month]++;
              } else if (role == 'teacher') {
                teacherCountsByMonth[month]++;
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ Error processing user creation date: $e');
      }
    }
    
    // Calculate cumulative counts (running total)
    int studentCumulative = 0;
    int teacherCumulative = 0;
    
    final studentSpots = List.generate(12, (index) {
      studentCumulative += studentCountsByMonth[index];
      return FlSpot(index.toDouble(), studentCumulative.toDouble());
    });
    
    final teacherSpots = List.generate(12, (index) {
      teacherCumulative += teacherCountsByMonth[index];
      return FlSpot(index.toDouble(), teacherCumulative.toDouble());
    });
    
    // Find max value for Y-axis scaling
    final maxValue = [
      studentCumulative,
      teacherCumulative,
      1, // Minimum of 1 to avoid division by zero
    ].reduce((a, b) => a > b ? a : b);
    
    final maxY = maxValue > 0 ? (maxValue * 1.2).ceilToDouble().clamp(5.0, double.infinity) : 10.0;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[index],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Students line
          LineChartBarData(
            spots: studentSpots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.9),
                const Color(0xFF34D399).withOpacity(0.5),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.3),
                  const Color(0xFF34D399).withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Teachers line
          LineChartBarData(
            spots: teacherSpots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.9),
                const Color(0xFF60A5FA).withOpacity(0.5),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.3),
                  const Color(0xFF60A5FA).withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(10),
            tooltipBgColor: Colors.white.withOpacity(0.95),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((LineBarSpot touchedBarSpot) {
                final value = touchedBarSpot.y.toInt();
                String label = '';
                Color color = Colors.white;
                
                if (touchedBarSpot.barIndex == 0) {
                  label = 'Students';
                  color = const Color(0xFF10B981);
                } else if (touchedBarSpot.barIndex == 1) {
                  label = 'Teachers';
                  color = const Color(0xFF3B82F6);
                }
                
                final monthIndex = touchedBarSpot.x.toInt();
                final monthName = monthIndex >= 0 && monthIndex < months.length 
                    ? months[monthIndex] 
                    : '';
                
                return LineTooltipItem(
                  '$label\n$value users',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: monthName.isNotEmpty ? [
                    TextSpan(
                      text: '\n$monthName',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ] : null,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserCategoryCard({
    required String label,
    required int count,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
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

