import 'package:eat_right/utils/constants/colors.dart'; // Use theme colors
import 'package:eat_right/utils/constants/sizes.dart'; // Use Sizes
import 'package:flutter/material.dart';

class NutrientCard extends StatelessWidget {
  final String name;
  final String valueString; // Pre-formatted value + unit (e.g., "50.5 mg")
  final double percent; // Progress value (e.g., 0.5 for 50%) - can be > 1.0
  final Color progressColor;
  final IconData iconData;

  const NutrientCard({
    super.key,
    required this.name,
    required this.valueString,
    required this.percent,
    required this.progressColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Determine background based on theme
    final cardBackgroundColor =
        isDarkMode
            ? SColors.darkGrey.withOpacity(
              0.7,
            ) // Slightly darker grey for dark mode
            : SColors.lightGrey.withOpacity(
              0.8,
            ); // Use light grey for light mode

    return Container(
      padding: const EdgeInsets.all(Sizes.m), // Consistent padding
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(
          Sizes.cardRadiusMd,
        ), // Consistent radius
        border: Border.all(
          color: Theme.of(
            context,
          ).dividerColor.withOpacity(0.5), // Subtle border
          width: 0.5,
        ),
        // Optional: subtle shadow
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.03),
        //     blurRadius: 5,
        //     offset: Offset(0, 2),
        //   )
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
        children: [
          // Top Row: Nutrient Name and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Allow name to wrap if long
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ), // Slightly bolder name
                  maxLines: 2, // Allow wrapping
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Sizes.xs),
              Icon(
                iconData, // Use passed icon data
                color: progressColor, // Color icon based on progress
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: Sizes.s), // Space before progress
          // Progress Indicator
          LinearProgressIndicator(
            // Clamp value between 0.0 and 1.0 for visual representation,
            // but allow percent > 1.0 for color calculation and display text
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.5), // Use theme color
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(
              Sizes.borderRadiusSm,
            ), // Rounded corners
          ),
          const SizedBox(height: Sizes.s), // Space after progress
          // Bottom Row: Values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current Value + Unit
              Text(
                valueString, // Display pre-formatted value string
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              // Percentage Value
              Text(
                '${(percent * 100).toStringAsFixed(0)}%', // Format percentage
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor, // Color percentage text
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// import 'package:eat_right/data/services/logic/new_logic/nutrient_controller.dart';
// import 'package:eat_right/temp/custom_icons.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NutrientCardController extends GetxController {
//   // final LogicController logic = Get.find<LogicController>();

//   String getUnit(String name) {
//     return NutrientController.instance.getUnit(name);
//   }

//   Color getColorForPercent(double percent) {
//     return NutrientController.instance.getColorForPercent(percent);
//   }
// }

// class NutrientCard extends StatelessWidget {
//   final Map<String, dynamic> nutrient;
//   final Map<String, double> dailyIntake;

//   const NutrientCard({
//     super.key,
//     required this.nutrient,
//     required this.dailyIntake,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final NutrientCardController controller = Get.put(NutrientCardController());

//     final name = nutrient['Nutrient'];
//     final current = dailyIntake[name] ?? 0.0;
//     final total =
//         double.tryParse(
//           nutrient['Current Daily Value'].replaceAll(RegExp(r'[^0-9\.]'), ''),
//         ) ??
//         0.0;
//     final percent = current / total;
//     final unit = controller.getUnit(name);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDarkMode ? SColors.black : SColors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Nutrient Name and Icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   name,
//                   // style:
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Icon(
//                 CustomIcons.getNutrientIcon(name),
//                 color: controller.getColorForPercent(percent),
//                 size: 20,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // Progress Indicator
//           LinearProgressIndicator(
//             value: percent,
//             backgroundColor: Theme.of(
//               context,
//             ).colorScheme.tertiary.withOpacity(0.1),
//             valueColor: AlwaysStoppedAnimation<Color>(
//               controller.getColorForPercent(percent),
//             ),
//             minHeight: 6,
//           ),

//           // Values
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '${current.toStringAsFixed(1)}$unit',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//               ),
//               Text(
//                 '${(percent * 100).toStringAsFixed(0)}%',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: controller.getColorForPercent(percent),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
