import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'filtered_users_screen.dart';
import 'add_user_screen.dart' show showAddUserModal;

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
              
              // User Overview - Upper Left
              if (!_isLoading && _errorMessage == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      const Text(
                        'User Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  // Graph Section - Fixed at top
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Container(
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
                                  ),
                                  
                                  // Centered Cards Section
                                  Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    ),
                                  ),
                                ],
                              );
                            },
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

  void _openCreateUser() async {
    await showAddUserModal(
      context,
      onUserCreated: () => _loadUsers(),
    );
    await _loadUsers();
  }

}

