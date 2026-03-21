import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DynamicBarChart extends StatelessWidget {
  final List<String> labels;
  final List<List<double>> data;
  final Color lastPeriodColor;
  final Color currentPeriodColor;

  const DynamicBarChart({
    super.key,
    required this.labels,
    required this.data,
    this.lastPeriodColor = const Color(0xff4A4E69), // Example muted color
    this.currentPeriodColor = const Color(0xff2D68FF),
  });

  @override
  Widget build(BuildContext context) {
    // 1. Find the raw highest value in your data
    double highestValue = 0;
    for (var pair in data) {
      highestValue = max(highestValue, max(pair[0], pair[1]));
    }

    // 2. Snap to the nearest 5
    double calculatedMaxY;
    if (highestValue == 0) {
      calculatedMaxY = 10; // Default if no data
    } else if (highestValue % 5 == 0) {
      calculatedMaxY = highestValue; // Already a multiple of 5, keep it
    } else {
      calculatedMaxY = (highestValue / 5).ceil() * 5.0; // Round up to next 5
    }

    // 3. Set interval to have exactly 5 sections
    double intervalValue = calculatedMaxY / 5;

    // 4. Add a tiny "painting padding" so the top line isn't clipped
    double chartLimitY = calculatedMaxY + (intervalValue * 0.05);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffffffff), // Matching your card color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(3, 3), // Bottom-right shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 0, 15),
            child: Text(
              "WEEKLY PROGRESS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.6,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartLimitY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // 1. Set the background color to white
                    getTooltipColor: (group) {
                      // We look at the first rod of the group to determine the base color
                      // Or you can use: group.barRods[0].color
                      return group.barRods[0].color!.withValues(alpha: 0.9);
                    },

                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,

                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // Get the Day Label (Monday, Tuesday, etc.)
                      String day = labels[groupIndex];

                      // Determine if it's "Last" or "This" week based on the rodIndex
                      // In your _generateGroups, 0 is Last Week, 1 is This Week
                      String weekLabel = rodIndex == 0 ? "(Last)" : "(This)";

                      return BarTooltipItem(
                        '$day $weekLabel\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: rod.toY.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white, // Matches the bar color
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ), // Tooltip enabled
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: intervalValue,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12, // --- X-AXIS FONT SIZE ---
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: intervalValue,
                      getTitlesWidget: (value, meta) {
                        // Hide labels that exceed our intended MaxY (the tiny 0.05 padding)
                        if (value > calculatedMaxY) return const SizedBox();

                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                // --- GRID LINES (Dashed Gray) ---
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: intervalValue,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ), // Clean look
                borderData: FlBorderData(show: false),
                barGroups: _generateGroups(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // --- THE LEGEND ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("Last Week", lastPeriodColor),
              const SizedBox(width: 24),
              _buildLegendItem("This Week", currentPeriodColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateGroups() {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barsSpace: 0, // --- REMOVES GAP BETWEEN BARS ---
        barRods: [
          BarChartRodData(
            toY: data[index][0],
            color: lastPeriodColor,
            width: 12, // Increased width for "Square" look
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
          BarChartRodData(
            toY: data[index][1],
            color: currentPeriodColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ],
      );
    });
  }
}
