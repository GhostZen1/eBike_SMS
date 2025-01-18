import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ebikesms/modules/global_import.dart';

class PieChartWidget extends StatelessWidget {
  final String monthName;
  final int monthIndex;
  final double totalToday;
  final double totalWeek;
  final double totalMonth;

  const PieChartWidget({
    Key? key,
    required this.monthName,
    required this.monthIndex,
    required this.totalToday,
    required this.totalWeek,
    required this.totalMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prepare data for the Pie chart
    final totalRevenue = totalToday + totalWeek + totalMonth;
    final todayPercentage = totalToday / totalRevenue * 100;
    final weekPercentage = totalWeek / totalRevenue * 100;
    final monthPercentage = totalMonth / totalRevenue * 100;

    return Column(
      children: [
        // Pie chart with month name in the center
        SizedBox(
          height: 250,
          width: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: todayPercentage,
                      color: ColorConstant.pink,
                      radius: 15,
                      titleStyle: const TextStyle(
                        fontSize: 0, // Hide titles in the chart
                      ),
                    ),
                    PieChartSectionData(
                      value: weekPercentage,
                      color: ColorConstant.yellow,
                      radius: 15,
                      titleStyle: const TextStyle(
                        fontSize: 0, // Hide titles in the chart
                      ),
                    ),
                    PieChartSectionData(
                      value: monthPercentage,
                      color: ColorConstant.darkBlue,
                      radius: 15,
                      titleStyle: const TextStyle(
                        fontSize: 0, // Hide titles in the chart
                      ),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 90,
                  startDegreeOffset: 90, // This adjusts the starting point of the pie chart
                ),
              ),
              // Month name in the center of the donut
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Inline Legend Section
        _buildLegend(),
      ],
    );
  }

  // Widget for the Inline Legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Align items in the center
      children: [
        _buildLegendRow(ColorConstant.pink, 'Today', totalToday),
        _buildLegendRow(ColorConstant.yellow, 'Week', totalWeek),
        _buildLegendRow(ColorConstant.darkBlue, 'Month', totalMonth),
      ],
    );
  }

  // Helper function to build each legend item
  Widget _buildLegendRow(Color color, String label, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Title and Color on the same line
          
          Row(
            children: [
              Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Total displayed below the label
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'RM ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
