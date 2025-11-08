import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart'; // Import the controller
import 'package:eat_right/temp/custom_icons.dart';
import 'package:eat_right/temp/dv_values.dart';
import 'package:eat_right/temp/widgets/nutrient_card.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:eat_right/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX

class DetailedNutrientsCard extends StatelessWidget {
  // Removed dailyIntake parameter
  const DetailedNutrientsCard({super.key});

  // --- Helper Functions remain the same ---
  Map<String, dynamic>? _getNutrientDefinition(String nutrientName) {
    return nutrientData.firstWhereOrNull(
      (data) => data['Nutrient']?.toLowerCase() == nutrientName.toLowerCase(),
    );
  }

  Color _getColorForPercent(BuildContext context, double percent) {
    final Color lowColor = Colors.lightBlue.shade400;
    final Color goodColor = Theme.of(context).colorScheme.primary;
    final Color highColor = Theme.of(context).colorScheme.error;

    if (percent < 0.5) return lowColor;
    if (percent <= 1.1) return goodColor;
    return highColor;
  }

  String _getUnit(Map<String, dynamic>? definition) {
    final dvString = definition?['Current Daily Value'] as String?;
    if (dvString == null) return '';
    final units = [
      'mcg DFE',
      'mcg RAE',
      'mg NE',
      'mcg',
      'mg',
      'g',
      'IU',
      'kcal',
      'alpha-tocopherol',
    ]; // Check longer specific units first
    for (var unit in units) {
      if (RegExp(
        r'\b' + unit + r'\b',
        caseSensitive: false,
      ).hasMatch(dvString)) {
        return unit;
      }
    }
    // Fallback for base units if specific not found
    if (RegExp(r'\bmg\b', caseSensitive: false).hasMatch(dvString)) return 'mg';
    if (RegExp(r'\bg\b', caseSensitive: false).hasMatch(dvString)) return 'g';
    if (RegExp(r'\bIU\b', caseSensitive: false).hasMatch(dvString)) return 'IU';
    if (RegExp(r'\bkcal\b', caseSensitive: false).hasMatch(dvString)) {
      return 'kcal';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Get the controller instance inside build
    final controller = DailyIntakeController.instance;
    final isDarkMode = SHelperFunctions.isDarkMode(context);

    // Use Obx to react to changes in the controller's state
    return Obx(() {
      final intake = controller.currentDailyIntake;
      final totalNutrients =
          intake?.totalNutrients ?? {}; // Default to empty map

      // Process the dailyIntake data inside Obx
      final List<Widget> nutrientCards = [];
      totalNutrients.forEach((nutrientName, currentAmount) {
        if (currentAmount <= 0.01) return;

        final definition = _getNutrientDefinition(nutrientName);
        // Filter out macros shown elsewhere and nutrients without definitions
        if (definition == null ||
            definition.isEmpty ||
            [
              'energy', // Use lowercase for comparison
              'protein',
              'fat',
              'carbohydrate',
              'fiber',
              'calories', // Also exclude 'calories' if it exists
            ].contains(nutrientName.toLowerCase())) {
          return;
        }

        final dvString = definition['Current Daily Value'] as String?;
        double totalDV = 0.0;
        if (dvString != null) {
          totalDV =
              double.tryParse(dvString.replaceAll(RegExp(r'[^0-9\.]'), '')) ??
              0.0;
        }

        final double percent = (totalDV > 0) ? (currentAmount / totalDV) : 0.0;
        final Color progressColor = _getColorForPercent(context, percent);
        final String unit = _getUnit(definition);
        // Ensure valueString formats correctly even for integers
        final String valueString =
            '${currentAmount.toStringAsFixed(currentAmount.truncateToDouble() == currentAmount ? 0 : 1)} $unit'
                .trim();
        final IconData iconData = CustomIcons.getNutrientIcon(nutrientName);

        nutrientCards.add(
          NutrientCard(
            name: nutrientName,
            valueString: valueString,
            percent: percent,
            progressColor: progressColor,
            iconData: iconData,
          ),
        );
      });

      // Sort cards alphabetically
      nutrientCards.sort(
        (a, b) => (a as NutrientCard).name.compareTo((b as NutrientCard).name),
      );

      // Build the UI based on the processed data
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace,
          vertical: Sizes.spaceBtwItems,
        ),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).cardColor.withOpacity(isDarkMode ? 0.7 : 1.0),
          borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Sizes.m,
                right: Sizes.xs,
                top: Sizes.s,
                bottom: Sizes.s,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detailed Nutrients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    tooltip: "Nutrient breakdown based on daily values",
                    onPressed: () {
                      SHelperFunctions.showAlert(
                        "About Nutrients",
                        "This section shows a detailed breakdown of your nutrient intake compared to recommended daily values (DV). Only nutrients with recorded intake are shown.",
                      );
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),

            // Use helper for empty state
            nutrientCards.isEmpty
                ? _buildEmptyState(context, totalNutrients.isEmpty)
                : Padding(
                  padding: const EdgeInsets.all(Sizes.m),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: Sizes.spaceBtwItems,
                    crossAxisSpacing: Sizes.spaceBtwItems,
                    children: nutrientCards,
                  ),
                ),
          ],
        ),
      );
    }); // End Obx
  }

  // Helper for empty state
  Widget _buildEmptyState(BuildContext context, bool noIntakeAtAll) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.m),
      child: Center(
        child: Text(
          noIntakeAtAll
              ? 'Log meals to see nutrient details.'
              : 'No detailed nutrients tracked yet for today.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).disabledColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
// import 'package:eat_right/temp/custom_icons.dart'; // For getNutrientIcon
// import 'package:eat_right/temp/dv_values.dart'; // Your static DV data
// import 'package:eat_right/temp/widgets/nutrient_card.dart'; // Import updated NutrientCard
// import 'package:eat_right/utils/constants/sizes.dart';
// import 'package:eat_right/utils/helpers/helper_functions.dart'; // For showAlert, isDarkMode
// import 'package:flutter/material.dart';
// // No GetX controller needed for this widget anymore
// // import 'package:get/get.dart';

// class DetailedNutrientsCard extends StatelessWidget {
//   final Map<String, double> dailyIntake; // Nutrient name -> consumed amount

//   const DetailedNutrientsCard({super.key, required this.dailyIntake});

//   // --- Helper Functions moved inside the widget ---

//   // Finds the static definition (DV, unit) for a nutrient
//   Map<String, dynamic>? _getNutrientDefinition(String nutrientName) {
//     return nutrientData.firstWhere(
//       (data) => data['Nutrient'] == nutrientName,
//       orElse: () => <String, dynamic>{}, // Return empty map if not found
//     );
//   }

//   // Determines color based on percentage of DV
//   Color _getColorForPercent(BuildContext context, double percent) {
//     // Use Theme colors for better adaptability
//     final Color lowColor = Colors.blue.shade300; // Example low color
//     final Color goodColor =
//         Theme.of(context).colorScheme.primary; // Example good color
//     final Color highColor =
//         Theme.of(context).colorScheme.error; // Example high color

//     if (percent < 0.5) return lowColor; // Below 50%
//     if (percent <= 1.1) return goodColor; // 50% - 110% (allow slight overshoot)
//     return highColor; // Above 110%
//   }

//   // Gets the unit string (e.g., "mg", "g")
//   String _getUnit(Map<String, dynamic>? definition) {
//     final dvString = definition?['Current Daily Value'] as String?;
//     if (dvString == null) return '';
//     // Basic extraction, might need refinement based on your string format
//     if (dvString.contains("mg")) return 'mg';
//     if (dvString.contains("mcg")) return 'mcg';
//     if (dvString.contains("g")) return 'g';
//     if (dvString.contains("IU")) return 'IU'; // Add other units as needed
//     return ''; // Fallback
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = SHelperFunctions.isDarkMode(context);

//     // Process the dailyIntake data to create NutrientCard widgets
//     final List<Widget> nutrientCards = [];
//     dailyIntake.forEach((nutrientName, currentAmount) {
//       // Skip if amount is zero or negligible
//       if (currentAmount <= 0.01) return;

//       final definition = _getNutrientDefinition(nutrientName);
//       // Skip nutrients not found in our static definitions (unless you want to display them differently)
//       if (definition == null || definition.isEmpty) return;

//       // Extract DV and calculate percentage
//       final dvString = definition['Current Daily Value'] as String?;
//       double totalDV = 0.0;
//       if (dvString != null) {
//         totalDV =
//             double.tryParse(dvString.replaceAll(RegExp(r'[^0-9\.]'), '')) ??
//             0.0;
//       }

//       // Avoid division by zero
//       final double percent = (totalDV > 0) ? (currentAmount / totalDV) : 0.0;
//       final Color progressColor = _getColorForPercent(context, percent);
//       final String unit = _getUnit(definition);
//       final String valueString =
//           '${currentAmount.toStringAsFixed(1)} $unit'.trim();
//       final IconData iconData = CustomIcons.getNutrientIcon(nutrientName);

//       nutrientCards.add(
//         NutrientCard(
//           name: nutrientName,
//           valueString: valueString,
//           percent: percent,
//           progressColor: progressColor,
//           iconData: iconData,
//         ),
//       );
//     });

//     // Sort cards alphabetically by name (optional)
//     nutrientCards.sort(
//       (a, b) => (a as NutrientCard).name.compareTo((b as NutrientCard).name),
//     );

//     return Container(
//       margin: const EdgeInsets.symmetric(
//         horizontal: Sizes.defaultSpace,
//         vertical: Sizes.spaceBtwItems,
//       ), // Use consistent margins
//       decoration: BoxDecoration(
//         color: Theme.of(
//           context,
//         ).cardColor.withOpacity(isDarkMode ? 0.7 : 1.0), // Adjust opacity
//         borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
//         border: Border.all(
//           color: Theme.of(context).dividerColor.withOpacity(0.5),
//         ), // Subtle border
//         boxShadow: [
//           // Subtle shadow
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Section
//           Padding(
//             padding: const EdgeInsets.only(
//               left: Sizes.m,
//               right: Sizes.xs,
//               top: Sizes.s,
//               bottom: Sizes.s,
//             ), // Adjusted padding
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Detailed Nutrients',
//                   style:
//                       Theme.of(context).textTheme.titleLarge, // Use theme style
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.info_outline_rounded,
//                     size: 20,
//                     color: Theme.of(context).textTheme.bodySmall?.color,
//                   ), // Smaller icon
//                   tooltip: "Nutrient breakdown based on daily values",
//                   onPressed: () {
//                     SHelperFunctions.showAlert(
//                       "About Nutrients",
//                       "This section shows a detailed breakdown of your nutrient intake compared to recommended daily values (DV).",
//                     );
//                   },
//                   visualDensity: VisualDensity.compact,
//                   padding: EdgeInsets.zero,
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, thickness: 0.5), // Add divider
//           // Handle Empty State
//           if (nutrientCards.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(Sizes.m),
//               child: Center(
//                 child: Text(
//                   dailyIntake.isEmpty
//                       ? 'Log meals to see nutrient details.' // Message if no intake at all
//                       : 'No detailed nutrients tracked yet.', // Message if intake exists but no matching DVs
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).disabledColor,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             )
//           else
//             // Nutrients Grid
//             Padding(
//               padding: const EdgeInsets.all(Sizes.m), // Padding around the grid
//               child: GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2, // Fixed 2 columns
//                 childAspectRatio: 1.6, // Adjust aspect ratio for better fit
//                 mainAxisSpacing: Sizes.spaceBtwItems,
//                 crossAxisSpacing: Sizes.spaceBtwItems,
//                 children: nutrientCards, // Display the processed cards
//               ),
//             ),
//           // const SizedBox(height: Sizes.spaceBtwItems), // Add padding at bottom if needed
//         ],
//       ),
//     );
//   }
// }
// // import 'package:eat_right/temp/dv_values.dart';
// // import 'package:eat_right/temp/widgets/nutrient_card.dart';
// // import 'package:eat_right/utils/constants/colors.dart';
// // import 'package:eat_right/utils/constants/sizes.dart';
// // import 'package:eat_right/utils/helpers/helper_functions.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// // class DetailedNutrientsCardController extends GetxController {
// //   // Filter nutrients based on conditions
// //   List<Map<String, dynamic>> getFilteredNutrients(
// //     Map<String, double> dailyIntake,
// //   ) {
// //     return nutrientData.where((nutrient) {
// //       final name = nutrient['Nutrient'];
// //       final current = dailyIntake[name] ?? 0.0;
// //       return current > 0.0 && !['Added Sugars', 'Saturated Fat'].contains(name);
// //     }).toList();
// //   }
// // }

// // class DetailedNutrientsCard extends StatelessWidget {
// //   final Map<String, double> dailyIntake;

// //   const DetailedNutrientsCard({super.key, required this.dailyIntake});

// //   @override
// //   Widget build(BuildContext context) {
// //     final DetailedNutrientsCardController controller = Get.put(
// //       DetailedNutrientsCardController(),
// //     );
// //     final isDarkMode = SHelperFunctions.isDarkMode(context);

// //     return Container(
// //       margin: const EdgeInsets.all(Sizes.defaultSpace),
// //       decoration: BoxDecoration(
// //         color:
// //             isDarkMode
// //                 ? SColors.darkGrey.withAlpha(50)
// //                 : SColors.lightGrey.withAlpha(75),
// //         borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Header Section
// //           Padding(
// //             padding: const EdgeInsets.all(Sizes.spaceBtwItems),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'Detailed Nutrients',
// //                   style: Theme.of(context).textTheme.headlineMedium,
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.info_outline),
// //                   onPressed: () {
// //                     SHelperFunctions.showAlert(
// //                       "About Nutrients",
// //                       "This section shows a detailed breakdown of your nutrient intake. Values are shown as a percentage of daily recommended intake.",
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //           if (dailyIntake.isEmpty)
// //             Padding(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: Sizes.spaceBtwItems,
// //               ),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Icon(Icons.restaurant_menu, size: Sizes.iconMd),
// //                   const SizedBox(width: Sizes.spaceBtwInputFields),
// //                   Expanded(
// //                     child: Text(
// //                       'Log your meals to see a detailed nutrient breakdown.',
// //                       style: Theme.of(context).textTheme.labelMedium,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //           // Nutrients Grid
// //           if (dailyIntake.isNotEmpty)
// //             Padding(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: Sizes.spaceBtwItems,
// //               ),
// //               child: GridView.count(
// //                 padding: const EdgeInsets.all(Sizes.s),
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 crossAxisCount: 2,
// //                 childAspectRatio: 1.4,
// //                 mainAxisSpacing: Sizes.spaceBtwItems,
// //                 crossAxisSpacing: Sizes.spaceBtwItems,
// //                 children:
// //                     controller
// //                         .getFilteredNutrients(dailyIntake)
// //                         .map(
// //                           (nutrient) => NutrientCard(
// //                             nutrient: nutrient,
// //                             dailyIntake: dailyIntake,
// //                           ),
// //                         )
// //                         .toList(),
// //               ),
// //             ),
// //           const SizedBox(height: Sizes.spaceBtwItems),
// //         ],
// //       ),
// //     );
// //   }
// // }
