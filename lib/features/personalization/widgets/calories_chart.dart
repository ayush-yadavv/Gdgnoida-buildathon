import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CaloriesChart extends StatelessWidget {
  final Map<DateTime, DailyIntakeModel> dailyIntakes;

  const CaloriesChart({super.key, required this.dailyIntakes});

  // Daily calorie value from nutrient_dv.dart
  static const double dailyCalorieValue = 2540.0;

  @override
  Widget build(BuildContext context) {
    // Convert the map to a list of data points for the chart
    final data = dailyIntakes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // If no data, show a message
    if (data.isEmpty) {
      return const Center(child: Text('No calorie data available'));
    }

    // Helper to get calories from daily intake
    double getCalories(DailyIntakeModel? intake) {
      if (intake == null) return 0.0;
      return intake.totalNutrients['calories'] ??
          intake.totalNutrients['Calories'] ??
          intake.totalNutrients['ENERC_KCAL'] ??
          0.0;
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Calories',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Goal: ${dailyCalorieValue.toInt()} kcal',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) {
                  if ((value - dailyCalorieValue).abs() < 0.1) {
                    return FlLine(
                      color: colorScheme.primary,
                      strokeWidth: 1.2,
                      dashArray: [4, 4],
                    );
                  }
                  return FlLine(color: theme.dividerColor, strokeWidth: 0.5);
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
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            '${data[value.toInt()].key.day}',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if ((value - dailyCalorieValue).abs() < 0.1) {
                        return Text(
                          '${value.toInt()}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        value.toInt().toString(),
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: data.length > 1 ? (data.length - 1).toDouble() : 1,
              minY: 0,
              maxY:
                  (data
                              .map((e) => getCalories(e.value))
                              .followedBy([dailyCalorieValue])
                              .reduce((a, b) => a > b ? a : b) *
                          1.2)
                      .toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      getCalories(entry.value.value),
                    );
                  }).toList(),
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Last ${data.length} days',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
