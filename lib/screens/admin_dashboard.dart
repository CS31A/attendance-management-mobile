import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'teachers_management_screen.dart';
import 'students_management_screen.dart';
import 'users_management_screen.dart';
import 'user_management_hub.dart';
import '../services/app_data.dart';
import 'reports_screen.dart';

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
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: _getSelectedContent(),
            ),
          ],
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
        return const UserManagementHub();
      case 2:
        return _buildReportsContent();
      case 3:
        return _buildClassesContent();
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
          
          const SizedBox(height: 24),
          
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
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
        )),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, Christian Dave',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Profile Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
                  fit: BoxFit.cover,
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
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
        )),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            // Blue highlighted card - Total Registered (not clickable)
            _buildModernStatCard(
              title: 'Total Registered',
              value: '1,336',
              progress: 0.7,
              color: Colors.blue,
              bgColor: const Color(0xFF1E3A8A),
              isHighlighted: true,
              onTap: null, // Not clickable - display only
            ),
            // Total Students (clickable)
            _buildModernStatCard(
              title: 'Total Students',
              value: '1,247',
              progress: 0.3,
              color: Colors.green,
              bgColor: Colors.white,
              isHighlighted: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentsManagementScreen(),
                  ),
                );
              },
            ),
            // Total Teachers (clickable)
            _buildModernStatCard(
              title: 'Total Teachers',
              value: '89',
              progress: 0.7,
              color: Colors.orange,
              bgColor: Colors.white,
              isHighlighted: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeachersManagementScreen(),
                  ),
                );
              },
            ),
            // User Management (clickable)
            _buildModernStatCard(
              title: 'User Management',
              value: '1,336',
              progress: 0.7,
              color: Colors.purple,
              bgColor: Colors.white,
              isHighlighted: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersManagementScreen(),
                  ),
                );
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
    required Color color,
    required Color bgColor,
    required bool isHighlighted,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isHighlighted 
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isHighlighted ? Colors.white : color,
                          borderRadius: BorderRadius.circular(2),
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
                    color: isHighlighted ? Colors.white70 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
        )),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: ['Monthly', 'Weekly', 'Today'].map((period) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == period 
                                ? Colors.blue 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedPeriod == period 
                                  ? Colors.white 
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                            if (value.toInt() >= 0 && value.toInt() < titles.length) {
                              return Text(
                                titles[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 60,
                    lineBarsData: [
                      // Pink line (lighter)
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 30),
                          const FlSpot(1, 45),
                          const FlSpot(2, 35),
                          const FlSpot(3, 50),
                          const FlSpot(4, 40),
                          const FlSpot(5, 55),
                          const FlSpot(6, 45),
                        ],
                        isCurved: true,
                        color: Colors.pink.withOpacity(0.7),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Dark line (main)
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 20),
                          const FlSpot(1, 35),
                          const FlSpot(2, 25),
                          const FlSpot(3, 40),
                          const FlSpot(4, 15),
                          const FlSpot(5, 25),
                          const FlSpot(6, 20),
                        ],
                        isCurved: true,
                        color: Colors.black87,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildBottomNavigationBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        )),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Reports',
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