import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../providers/app_data.dart';
import '../main.dart';
import '../utils/responsive.dart';
import '../utils/glassmorphism.dart';
import 'users_management_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'classes_screen.dart';
import 'enrollment_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  int _selectedIndex = 0;
  int _notificationCount = 3;
  String _selectedPeriod = 'Monthly';

  // Stats
  bool _isLoading = false;
  String? _errorMessage;
  int _totalUsers = 0;
  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _totalAdmins = 0;

  // Attendance Stats (Mon-Fri)
  List<double> _attendanceStats = [0, 0, 0, 0, 0];

  late AnimationController _entranceController;
  late AnimationController _navigationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize entrance animation controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize navigation animation controller
    _navigationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Setup fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    // Setup slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    // Start entrance animation
    _entranceController.forward();

    // Load real data
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getUsers();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          final users = List<Map<String, dynamic>>.from(data);

          // Debug: Print all unique roles
          final uniqueRoles = users
              .map((u) => u['role']?.toString() ?? 'null')
              .toSet()
              .toList();
          print('🔍 Unique roles found: $uniqueRoles');
          
          // Debug: Print first 5 users with all their fields
          print('🔍 First 5 users data:');
          for (var i = 0; i < users.length && i < 5; i++) {
            print('  User $i: ${users[i]}');
          }
          
          // Debug: Count by role
          final studentCount = users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'student').length;
          final teacherCount = users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'teacher').length;
          final adminCount = users.where((u) => (u['role']?.toString() ?? '').toLowerCase() == 'admin').length;
          print('📊 Role counts - Students: $studentCount, Teachers: $teacherCount, Admins: $adminCount');

          if (mounted) {
            setState(() {
              _totalUsers = users.length;
              _totalStudents = studentCount;
              _totalTeachers = teacherCount;
              _totalAdmins = adminCount;

              // Debug: Print counts
              print('📊 Dashboard State - Total: $_totalUsers, Students: $_totalStudents, Teachers: $_totalTeachers, Admins: $_totalAdmins');

              // Initialize attendance stats to zero (as no classes started yet)
              _attendanceStats = [0, 0, 0, 0, 0];

              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to load stats';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load stats: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _navigationController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    setState(() {
      _selectedIndex = 0;
    });

    // Reset and play navigation animation
    _navigationController.reset();
    _navigationController.forward();

    // Reload stats when returning to dashboard
    _loadStats();
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
              // Main Content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _getSelectedContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const EnrollmentScreen();
      case 2:
        return const ClassesScreen();
      case 3:
        return UsersManagementScreen(
          onBackPressed: _navigateToDashboard,
        );
      case 4:
        return const ProfileScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile
            _buildModernHeader(),

            SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20)),

            // Debug info (temporary - remove after fixing)
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(Responsive.spacing(context, mobile: 8, tablet: 12, desktop: 16)),
                margin: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20)),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'Error: $_errorMessage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
              ),

            // Stats Grid (2x2) - Updated with management items
            _buildStatsGrid(),

            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),

            // Chart Section
            _buildChartSection(),

            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            // Logo
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
            const SizedBox(width: 12),
            // Dashboard Title
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Notification Icon
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // TODO: Implement notification panel
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            // Profile Icon (Circular)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 4; // Navigate to Profile screen
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GridView.count(
          crossAxisCount: Responsive.gridColumns(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20),
          crossAxisSpacing: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20),
          childAspectRatio: 1.0,
          children: [
            // Total Registered card
            _buildModernStatCard(
              title: 'Total Registered',
              value: _isLoading ? '...' : _totalUsers.toString(),
              progress: _totalUsers > 0 ? 1.0 : 0.0,
              gradientColors: [
                const Color(0xFF3B82F6),
                const Color(0xFF60A5FA)
              ],
              icon: Icons.people_alt,
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Go to Users Management
                });
              },
            ),
            // Total Students card
            _buildModernStatCard(
              title: 'Total Students',
              value: _isLoading ? '...' : _totalStudents.toString(),
              progress: _totalUsers > 0 ? (_totalStudents / _totalUsers) : 0.0,
              gradientColors: [
                const Color(0xFF10B981),
                const Color(0xFF34D399)
              ],
              icon: Icons.school,
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Go to Users Management
                });
              },
            ),
            // Total Teachers card
            _buildModernStatCard(
              title: 'Total Teachers',
              value: _isLoading ? '...' : _totalTeachers.toString(),
              progress: _totalUsers > 0 ? (_totalTeachers / _totalUsers) : 0.0,
              gradientColors: [
                const Color(0xFFF59E0B),
                const Color(0xFFFBBF24)
              ],
              icon: Icons.person_outline,
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Go to Users Management
                });
              },
            ),
            // User Management card
            _buildModernStatCard(
              title: 'Admins',
              value: _isLoading ? '...' : _totalAdmins.toString(),
              progress: _totalUsers > 0 ? (_totalAdmins / _totalUsers) : 0.0,
              gradientColors: [
                const Color(0xFF8B5CF6),
                const Color(0xFFA78BFA)
              ],
              icon: Icons.admin_panel_settings,
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Go to Users Management
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required double progress,
    required List<Color> gradientColors,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 6, tablet: 8, desktop: 10)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(Responsive.borderRadius(context) - 4),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: Responsive.iconSize(context, mobile: 18, tablet: 22, desktop: 26),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 8, tablet: 12, desktop: 16)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.headingFontSize(context, mobile: 20, tablet: 24, desktop: 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 2, tablet: 4, desktop: 6)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 11, tablet: 12, desktop: 14),
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildChartSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Attendance Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        child: _buildPeriodSelector(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.white.withOpacity(0.9),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()}%',
                                const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                String text = '';
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'Mon';
                                    break;
                                  case 1:
                                    text = 'Tue';
                                    break;
                                  case 2:
                                    text = 'Wed';
                                    break;
                                  case 3:
                                    text = 'Thu';
                                    break;
                                  case 4:
                                    text = 'Fri';
                                    break;
                                }
                                return Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                String text = '';
                                if (value == 0) {
                                  text = '0%';
                                } else if (value == 50) {
                                  text = '50%';
                                } else if (value == 100) {
                                  text = '100%';
                                }
                                return Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: List.generate(_attendanceStats.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: _attendanceStats[index],
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          );
                        }),
                      ),
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

  Widget _buildPeriodSelector() {
    final periods = ['Today', 'Weekly', 'Monthly'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        final blue = const Color(0xFF3B82F6);
        final lightBlue = const Color(0xFF60A5FA);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [blue, lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? blue : Colors.white.withOpacity(0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportsContent() {
    return const ReportsScreen();
  }

  Widget _buildClassesContent() {
    return const Center(
      child: Text(
        'Classes\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New System Update Available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap to view the latest features and improvements",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF3B82F6),
              size: 16,
            ),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
        currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
        ],
      ),
    );
  }
}
