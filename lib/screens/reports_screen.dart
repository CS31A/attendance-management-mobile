import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Attendance Reports",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ReportCard(
              title: '📈 Attendance Trends',
              child: SizedBox(
                height: screenHeight * 0.3,
                child: LineChart(_getAttendanceTrendsData()),
              ),
            ),
            const SizedBox(height: 20),
            _ReportCard(
              title: '📚 Attendance by Class',
              child: SizedBox(
                height: screenHeight * 0.3,
                child: BarChart(_getAttendanceByClassData()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _getAttendanceTrendsData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 200,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, _) {
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  months[value.toInt()],
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 150),
            FlSpot(1, 300),
            FlSpot(2, 200),
            FlSpot(3, 600),
            FlSpot(4, 400),
            FlSpot(5, 650),
            FlSpot(6, 950),
          ],
          isCurved: true,
          color: const Color(0xFF3B82F6),
          barWidth: 4,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF3B82F6).withOpacity(0.1),
          ),
          dotData: FlDotData(show: false),
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
      gridData: FlGridData(show: true, horizontalInterval: 20),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, interval: 20),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                labels[value.toInt()],
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: List.generate(labels.length, (index) {
        final isLate = labels[index] == 'Late';
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data[index],
              color: isLate ? const Color(0xFFEF4444) : const Color(0xFF60A5FA),
              width: 14,
              borderRadius: BorderRadius.circular(6),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
