import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ebikesms/modules/global_import.dart';

class PieChartWidget extends StatelessWidget {
  final String monthName;
  final List<double> weeklyTotals;

  const PieChartWidget({
    Key? key,
    required this.monthName,
    required this.weeklyTotals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total revenue
    double totalRevenue = weeklyTotals.fold(0.0, (sum, week) => sum + week);

    // Check if there is no data
    bool noData = totalRevenue == 0;

    // Prepare PieChart sections
    List<PieChartSectionData> sections = noData
        ? [
            // Default section for no data
            PieChartSectionData(
              value: 100,
              color: Colors.grey,
              radius: 15,
              title: '',
            ),
          ]
        : weeklyTotals.asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value / totalRevenue * 100;
            return PieChartSectionData(
              value: value,
              color: _getWeekColor(index),
              radius: 15,
              titleStyle: const TextStyle(fontSize: 0), // Remove titles
            );
          }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 90,
                  startDegreeOffset: 90,
                ),
              ),
              // Month name or "No Data" in the center of the donut
              Text(
                noData ? '$monthName \nNo Data' : monthName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (!noData) ...[
          const SizedBox(width: 20), // Space between chart and legend
          // Inline Legend Section, aligned vertically
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(weeklyTotals.length, (index) {
              return _buildLegendRow(
                _getWeekColor(index),
                'Week ${index + 1}',
                weeklyTotals[index],
              );
            }),
          ),
        ],
      ],
    );
  }

  // Helper function to build each legend item
  Widget _buildLegendRow(Color color, String label, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Week label and Color
          Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
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
        ],
      ),
    );
  }

  // Helper function to assign a color to each week
  Color _getWeekColor(int weekIndex) {
    const colors = [
      ColorConstant.pink,
      ColorConstant.yellow,
      ColorConstant.darkBlue,
      ColorConstant.lightBlue,
      ColorConstant.red,
    ];
    return colors[weekIndex % colors.length];
  }
}
