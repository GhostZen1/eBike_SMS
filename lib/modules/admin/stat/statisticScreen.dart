import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final String monthName; // Add monthName parameter

  const PieChartWidget({Key? key, required this.monthName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center, // Aligns the text at the center
        children: [
          PieChart(
            PieChartData(
              sections: _showingSections(),
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 70,
              startDegreeOffset: 180,
              sectionsSpace: 2,
            ),
          ),
          Text(
            monthName, // Display the month name
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // You can change the color to suit your design
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return [
      PieChartSectionData(
        color: Color(0xFF4A90E2),
        radius: 10,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Color(0xFF50E3C2),
        radius: 10,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Color(0xFFF5A623),
        radius: 10,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}
