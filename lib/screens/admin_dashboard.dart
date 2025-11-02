import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'teachers_management_screen.dart';
import 'students_management_screen.dart';
import 'users_management_screen.dart';
import 'user_management_hub.dart';
import '../services/app_data.dart';
import 'reports_screen.dart';
import 'admin_settings_screen.dart';
import 'profile_edit_screen.dart';
import '../models/user.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _notificationCount = 3;
  String _selectedPeriod = 'Monthly';
  
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
        return UsersManagementScreen(
          onBackPressed: _navigateToDashboard,
        );
      case 2:
        return ReportsScreen(
          onBackPressed: _navigateToDashboard,
        );
      case 3:
        return ProfileEditScreen(
          user: User(
            id: '1',
            name: 'Admin User',
            email: 'admin@example.com',
            role: 'admin',
          ),
        );
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile
          _buildModernHeader(),
          
          const SizedBox(height: 16),
          
          // Notification Card
          _buildNotificationCard(),
          
          const SizedBox(height: 16),
          
          // Stats Grid (2x2) - Updated with management items
          _buildStatsGrid(),
          
          const SizedBox(height: 24),
          
          // Chart Section
          _buildChartSection(),
          
          const SizedBox(height: 24),
        ],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, Christian Dave',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Profile Avatar - Made Clickable
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      user: User(
                        id: '1',
                        name: 'Admin User',
                        email: 'admin@example.com',
                        role: 'admin',
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            // Total Registered card with blue-purple gradient
            _buildModernStatCard(
              title: 'Total Registered',
              value: '1,336',
              progress: 0.7,
              gradientColors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
              icon: Icons.people_alt,
              onTap: null,
            ),
            // Total Students card with emerald-green gradient
            _buildModernStatCard(
              title: 'Total Students',
              value: '1,247',
              progress: 0.3,
              gradientColors: [const Color(0xFF10B981), const Color(0xFF34D399)],
              icon: Icons.school,
              onTap: () {
                // Navigation disabled for now
              },
            ),
            // Total Teachers card with orange-amber gradient
            _buildModernStatCard(
              title: 'Total Teachers',
              value: '89',
              progress: 0.7,
              gradientColors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
              icon: Icons.person_outline,
              onTap: () {
                // Navigation disabled for now
              },
            ),
            // User Management card with pink-rose gradient
            _buildModernStatCard(
              title: 'User Management',
              value: '1,336',
              progress: 0.7,
              gradientColors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
              icon: Icons.settings_applications,
              onTap: () {
                // Navigation disabled for now
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
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0].withOpacity(0.3),
                  gradientColors[1].withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gradientColors[0].withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
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
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
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
                                TextStyle(
                                  color: const Color(0xFF1E3A8A),
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
                                    color: Colors.white.withOpacity(0.9),
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
                                    color: Colors.white.withOpacity(0.9),
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
                        barGroups: [
                          // Monday - Blue gradient
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 88,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          ),
                          // Tuesday - Emerald gradient
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: 92,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          ),
                          // Wednesday - Orange gradient
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: 85,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          ),
                          // Thursday - Purple gradient
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: 78,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          ),
                          // Friday - Pink gradient
                          BarChartGroupData(
                            x: 4,
                            barRods: [
                              BarChartRodData(
                                toY: 90,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: const BorderRadius.all(Radius.circular(4)),
                              ),
                            ],
                          ),
                        ],
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
        final colors = [
          [const Color(0xFF7C3AED), const Color(0xFFA855F7)], // Purple gradient
          [const Color(0xFF059669), const Color(0xFF10B981)], // Emerald gradient
          [const Color(0xFFDC2626), const Color(0xFFEF4444)], // Red gradient
        ];
        final colorIndex = periods.indexOf(period) % colors.length;
        final gradientColors = colors[colorIndex];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? gradientColors[0].withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 1.5 : 1,
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
            child: Text(
              period,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to view the latest features and improvements",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () {
                  // Handle notification tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
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
                icon: Icon(Icons.people),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Teachers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}