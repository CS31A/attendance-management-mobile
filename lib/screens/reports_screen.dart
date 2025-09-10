import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsTheme {
  static const Color cardColor = Colors.white;
  static const Color chartLineColor = Color(0xFF5D9CEC);
  static const Color chartBarColor = Color(0xFF5D9CEC);
  static const Color lateAttendanceColor = Color(0xFFE74C3C);

  static const TextStyle sectionTitleStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black87,
  );
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Neutral background
        body: Column(
          children: [
            
            //const SizedBox(height: 12), // Small spacing only
            // Clean white tab bar
            //Material(
              //color: Colors.white,
              //elevation: 2,
              //child: const TabBar(
               // indicatorColor: Colors.blue,
                //labelColor: Colors.blue,
                //unselectedLabelColor: Colors.black54,
                //tabs: [
                //  Tab(text: 'Daily'),
                //  Tab(text: 'Week'),
                 // Tab(text: 'Monthly'),
              //  ],
              //),
            //),
            Expanded(
              child: TabBarView(
                children: [
                  _buildReportTab(context, screenHeight),
                  _buildReportTab(context, screenHeight),
                  _buildReportTab(context, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(BuildContext context, double height) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ReportCard(
            title: 'Attendance Trends',
            child: SizedBox(
              height: height * 0.25,
              child: LineChart(_getAttendanceTrendsData()),
            ),
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Attendance by Class',
            child: SizedBox(
              height: height * 0.25,
              child: BarChart(_getAttendanceByClassData()),
            ),
          ),
        ],
      ),
    );
  }

  // Chart Data

  LineChartData _getAttendanceTrendsData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  months[value.toInt() % months.length],
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
            interval: 1,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 150),
            FlSpot(1, 400),
            FlSpot(2, 250),
            FlSpot(3, 700),
            FlSpot(4, 300),
            FlSpot(5, 550),
            FlSpot(6, 950),
          ],
          isCurved: true,
          color: ReportsTheme.chartLineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: ReportsTheme.chartLineColor.withOpacity(0.15),
          ),
        ),
      ],
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 1000,
    );
  }

  BarChartData _getAttendanceByClassData() {
    const labels = ['Math', 'Science', 'English', 'History', 'Late'];
    const data = [30.0, 75.0, 55.0, 65.0, 20.0];
    return BarChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, interval: 20),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                labels[value.toInt()],
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ),
      barGroups: List.generate(labels.length, (index) {
        final isLate = labels[index] == 'Late';
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data[index],
              color: isLate
                  ? ReportsTheme.lateAttendanceColor
                  : ReportsTheme.chartBarColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
      maxY: 100,
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ReportCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReportsTheme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ReportsTheme.sectionTitleStyle),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
