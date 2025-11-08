import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:eat_right/temp/dv_values.dart'; // Import the DV values
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:percent_indicator/circular_percent_indicator.dart';

class MacronutrientSummaryCard extends StatelessWidget {
  const MacronutrientSummaryCard({super.key});

  // const MacronutrientSummaryCard({super.key});

  // Helper function to extract numeric goal from DV string
  double _getGoalFromDv(String nutrientName) {
    // ... (implementation remains the same) ...
    final nutrientInfo = nutrientData.firstWhereOrNull(
      (data) => data['Nutrient']?.toLowerCase() == nutrientName.toLowerCase(),
    );
    if (nutrientInfo != null) {
      final dvString = nutrientInfo['Current Daily Value'] as String?;
      if (dvString != null) {
        final numberPart = dvString.replaceAll(RegExp(r'[^0-9\.]'), '');
        return double.tryParse(numberPart) ?? 0.0;
      }
    }
    switch (nutrientName.toLowerCase()) {
      case 'energy':
        return 2000.0;
      case 'protein':
        return 50.0;
      case 'carbohydrate':
        return 275.0;
      case 'fat':
        return 78.0;
      default:
        return 0.0;
    }
  }

  // --- Dynamic Color Logic ---
  Color _getColorForMacroPercent(BuildContext context, double percent) {
    // Use Theme colors as base
    final Color lowColor = Colors.yellow.shade400;
    final Color goodColor = Theme.of(context).colorScheme.primary;
    final Color highColor = Theme.of(context).colorScheme.error; // Red for high

    if (percent < 0.5) return lowColor; // Under 50% - Low
    if (percent <= 1.1) return goodColor; // 50% to 110% - Good range
    return highColor; // Over 110% - High
  }

  @override
  Widget build(BuildContext context) {
    final controller = DailyIntakeController.instance;

    return Obx(() {
      final intake = controller.currentDailyIntake;
      final totalNutrients = intake?.totalNutrients ?? {};
      final calories = totalNutrients['calories'] ?? 0.0;
      final protein = totalNutrients['protein'] ?? 0.0;
      final carbs = totalNutrients['carbohydrates'] ?? 0.0;
      final fat = totalNutrients['fat'] ?? 0.0;

      final calorieGoal = _getGoalFromDv('Energy');
      final proteinGoal = _getGoalFromDv('Protein');
      final carbsGoal = _getGoalFromDv('Carbohydrate');
      final fatGoal = _getGoalFromDv('Fat');

      final caloriesPercent = calorieGoal > 0 ? (calories / calorieGoal) : 0.0;
      final proteinPercent = proteinGoal > 0 ? (protein / proteinGoal) : 0.0;
      final carbsPercent = carbsGoal > 0 ? (carbs / carbsGoal) : 0.0;
      final fatPercent = fatGoal > 0 ? (fat / fatGoal) : 0.0;

      final bool hasData = calories > 0 || protein > 0 || carbs > 0 || fat > 0;

      return Card(
        // ... (Container decoration remains the same) ...
        margin: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace,
          vertical: Sizes.spaceBtwItems / 2,
        ),
        elevation: 1,

        // padding: const EdgeInsets.all(Sizes.m),
        // color: Theme.of(context).cardColor.withOpacity(isDarkMode ? 0.7 : 1.0),
        // borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
        // border: Border.all(
        //   color: Theme.of(context).dividerColor.withOpacity(0.5),
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.04),
        //       blurRadius: 8,
        //       offset: const Offset(0, 3),
        //     ),
        //   ],
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.m,
            vertical: Sizes.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Macros Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline_rounded),
                    tooltip: "Summary based on general Daily Values (DV).",
                    onPressed: () => _showInfoDialog(
                      context,
                      calorieGoal,
                      proteinGoal,
                      carbsGoal,
                      fatGoal,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: Sizes.spaceBtwItems / 2, thickness: 0.5),

              !hasData
                  ? _buildEmptyState(context)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: Sizes.s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pass percent, remove static color
                          _buildMacroIndicator(
                            context,
                            label: 'Calories',
                            value: calories,
                            unit: 'kcal',
                            percent: caloriesPercent,
                            goal: calorieGoal,
                          ),
                          _buildMacroIndicator(
                            context,
                            label: 'Protein',
                            value: protein,
                            unit: 'g',
                            percent: proteinPercent,
                            goal: proteinGoal,
                          ),
                          _buildMacroIndicator(
                            context,
                            label: 'Carbs',
                            value: carbs,
                            unit: 'g',
                            percent: carbsPercent,
                            goal: carbsGoal,
                          ),
                          _buildMacroIndicator(
                            context,
                            label: 'Fat',
                            value: fat,
                            unit: 'g',
                            percent: fatPercent,
                            goal: fatGoal,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  // Updated helper widget
  Widget _buildMacroIndicator(
    BuildContext context, {
    required String label,
    required double value,
    required String unit,
    required double percent, // Percentage (can be > 1.0)
    required double goal,
    // Color parameter removed
  }) {
    // Determine color based on percentage
    final Color progressColor = _getColorForMacroPercent(context, percent);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 65,
            // height: 65,
            child: CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 5.0,
              animation: true,
              animationDuration: 800,
              // Clamp for indicator visual only
              percent: percent.clamp(0.0, 1.0),
              center: Text(
                "${(percent * 100).toStringAsFixed(0)}%", // Show actual percentage
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  // fontWeight: FontWeight.bold,
                  color: progressColor, // Use dynamic color for text
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: progressColor, // Use dynamic color
              backgroundColor: progressColor.withValues(
                alpha: 0.1,
              ), // Use dynamic color for background
            ),
          ),
          const SizedBox(height: Sizes.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            '${value.toStringAsFixed(0)}/${goal.toStringAsFixed(0)} $unit',
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper for empty state
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.m),
      child: Center(
        child: Text(
          "No macronutrient data logged yet.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showInfoDialog(
    BuildContext context,
    double cGoal,
    double pGoal,
    double chGoal,
    double fGoal,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,

      builder: (context) => AlertDialog(
        title: const Text('Macronutrient Info'),
        content: Text(
          "This card summarizes your intake compared to general Daily Values (DV):\n"
          "- Calories: ${cGoal.toStringAsFixed(0)} kcal\n"
          "- Protein: ${pGoal.toStringAsFixed(0)} g\n"
          "- Carbs: ${chGoal.toStringAsFixed(0)} g\n"
          "- Fat: ${fGoal.toStringAsFixed(0)} g\n\n",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
// import 'package:eat_right/utils/constants/sizes.dart';
// import 'package:flutter/material.dart';

// Widget MacronutrientSummaryCard(
//   BuildContext context,
//   Map<String, double> dailyIntake,
// ) {
//   final calories = dailyIntake['Energy'] ?? 0.0;
//   const calorieGoal = 2000.0;
//   final caloriePercent = (calories / calorieGoal);
//   return Container(
//     margin: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
//     padding: const EdgeInsets.all(Sizes.l),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Theme.of(context).colorScheme.primary,
//           Theme.of(context).colorScheme.primary.withOpacity(0.3),
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(24),
//       // boxShadow: [
//       //   BoxShadow(
//       //     color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//       //     blurRadius: 20,
//       //     offset: const Offset(5, 5),
//       //   ),
//       // ],
//     ),
//     child: Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 75,
//                   height: 75,
//                   child: CircularProgressIndicator(
//                     value: caloriePercent,
//                     backgroundColor: Colors.white24,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).colorScheme.onPrimary,
//                     ),
//                     strokeWidth: 10,
//                     strokeCap: StrokeCap.round,
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     '${(caloriePercent * 100).toStringAsFixed(0)}%',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onPrimary,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Calories',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.onPrimary,
//                     fontSize: 20,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 Text(
//                   '${calories.toStringAsFixed(0)} / ${calorieGoal.toStringAsFixed(0)} kcal',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.onPrimary,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 30),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildMacronutrientIndicator(
//               'Protein',
//               dailyIntake['Protein'] ?? 0.0,
//               50.0,
//               Icons.fitness_center,
//             ),
//             _buildMacronutrientIndicator(
//               'Carbs',
//               dailyIntake['Carbohydrate'] ?? 0.0,
//               275.0,
//               Icons.grain,
//             ),
//             _buildMacronutrientIndicator(
//               'Fat',
//               dailyIntake['Fat'] ?? 0.0,
//               78.0,
//               Icons.opacity,
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildMacronutrientIndicator(
//   String label,
//   double value,
//   double goal,
//   IconData icon,
// ) {
//   final percent = (value / goal).clamp(0.0, 1.0);
//   return Column(
//     spacing: 4,
//     children: [
//       Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: Colors.white, size: 32),
//       ),
//       Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontFamily: 'Poppins',
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '${value.toStringAsFixed(1)}g',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Poppins',
//             ),
//           ),
//           Text(
//             ' / ${goal.toStringAsFixed(1)}g',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               fontWeight: FontWeight.w400,
//               fontFamily: 'Poppins',
//             ),
//           ),
//         ],
//       ),
//       SizedBox(
//         height: 6,
//         width: 80,
//         child: LinearProgressIndicator(
//           value: percent,
//           backgroundColor: Colors.white24,
//           valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//           minHeight: 5,
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     ],
//   );
// }
