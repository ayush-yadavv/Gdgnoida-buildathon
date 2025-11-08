import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart'; // Import correct controller
import 'package:eat_right/temp/screens/detailed_day_view/detailed_day_view_page.dart';
import 'package:eat_right/temp/widgets/add_meal_manually_controller.dart'; // Assuming this is still needed
import 'package:eat_right/utils/constants/sizes.dart'; // Use Sizes
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodHistorySection extends StatelessWidget {
  // selectedDate is observed via the controller's currentDailyIntake
  const FoodHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the DailyIntakeController instance
    final dailyIntakeController = DailyIntakeController.instance;
    // final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Intake', // Changed title to reflect content
              style: Theme.of(context).textTheme.titleLarge,
            ),
            (dailyIntakeController.currentDailyIntake == null ||
                    dailyIntakeController.currentDailyIntake!.foodIds.isEmpty)
                ? IconButton(
                    // Info Button
                    icon: Icon(
                      Icons.info_outline_rounded, // Use rounded icon
                    ),
                    tooltip: "Summary of logged items for the selected day.",
                    onPressed: () => _showInfoDialog(context),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      "${dailyIntakeController.currentDailyIntake?.foodIds.length} Item${dailyIntakeController.currentDailyIntake?.foodIds.length == 1 ? '' : 's'}",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: Sizes.spaceBtwItems),

        // --- Body - Reacts to Daily Intake Changes ---
        Obx(() {
          // Observe the currentDailyIntake
          final intake = dailyIntakeController.currentDailyIntake;

          // Loading State (Optional - could check controller.isLoading)
          if (dailyIntakeController.isLoading.value && intake == null) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          // No Data State
          if (intake == null || intake.foodIds.isEmpty) {
            return _buildEmptyState(context);
          }

          // Data Available State
          return _buildSummaryContent(context, intake);
        }),

        // --- Add Manually Button (Keep if needed) ---
        const Divider(height: Sizes.defaultSpace),

        AddMealManuallyContainer(),
      ],
    );
  }

  // --- Helper Widgets for Content ---

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: Sizes.iconLg * 1.5,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: Sizes.s),
          Text(
            "Log your first meal!",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context, DailyIntakeModel intake) {
    final itemCount = intake.foodIds.length;
    final mealBreakdown = intake.mealTypeBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "$itemCount item${itemCount == 1 ? '' : 's'} logged:",
        //   style: Theme.of(
        //     context,
        //   ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        // ),
        // const SizedBox(height: Sizes.defaultSpace),
        if (mealBreakdown.isNotEmpty)
          _buildMealBreakdownSummary(context, mealBreakdown)
        else
          Padding(
            // Fallback if breakdown isn't populated yet
            padding: const EdgeInsets.only(
              left: Sizes.defaultSpace,
              top: Sizes.defaultSpace,
            ),
            child: Text(
              "Meal details unavailable.",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),

        const SizedBox(height: Sizes.spaceBtwItems),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.list_alt_rounded, size: 18),
            label: Text("View Full Day Details"),
            onPressed: () {
              // Navigate to the new page, passing the date
              final selectedDate = DailyIntakeController.instance.selectedDate;
              Get.to(() => DetailedDayViewPage(date: selectedDate));
            },
            // style: OutlinedButton.styleFrom(
            //   padding: EdgeInsets.symmetric(
            //     horizontal: Sizes.defaultSpace,
            //     vertical: Sizes.defaultSpace / 2,
            //   ),
            //   textStyle: Theme.of(context).textTheme.labelLarge,
            // ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealBreakdownSummary(
    BuildContext context,
    Map<String, double> breakdown,
  ) {
    // Sort entries for consistent order
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => _mealOrder(a.key).compareTo(_mealOrder(b.key)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...sortedEntries.map((entry) {
          final isLast = sortedEntries.last.key == entry.key;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMealIcon(entry.key),
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, thickness: 1),
            ],
          );
        }),
      ],
    );
  }

  // Helper to assign order to meal types for sorting
  int _mealOrder(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 1;
      case 'lunch':
        return 2;
      case 'dinner':
        return 3;
      case 'snacks':
        return 4;
      default:
        return 5;
    }
  }

  // Helper to get an icon for meal type
  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snacks':
        return Icons.fastfood_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }

  // --- Info Dialog ---
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Day Summary Info'),
        content: const Text(
          'This section provides a summary of the food items logged for the selected day, including the total count and a breakdown by meal type (based on consumption time). Click "View Full Day Details" for an itemized list.',
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
// import 'package:eat_right/data/repositories/Food_repository/food_history_controller.dart';
// import 'package:eat_right/temp/widgets/add_meal_manually_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class FoodHistoryCard extends StatelessWidget {
//   final DateTime selectedDate;
//   // final LogicController logic;

//   const FoodHistoryCard({
//     super.key,
//     required this.selectedDate,
//     // required this.logic,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final LogicController logic = Get.find<LogicController>();
//     final foodHistoryController = FoodHistoryController.instance;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).colorScheme.secondary.withOpacity(0.3),
//             Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//         //     blurRadius: 20,
//         //     offset: const Offset(5, 5),
//         //   ),
//         // ],
//       ),
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Today\'s Intake',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w500,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.info_outline,
//                   color: Theme.of(context).colorScheme.onTertiary,
//                 ),
//                 onPressed: () {
//                   // Show info dialog about nutrients
//                   showDialog(
//                     context: context,
//                     builder:
//                         (context) => AlertDialog(
//                           backgroundColor:
//                               Theme.of(context).colorScheme.surface,
//                           title: const Text('Food Items History'),
//                           content: const Text(
//                             'This section shows all the food items you have consumed today, along with their caloric values and timestamps.',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context),
//                               child: const Text('Got it'),
//                             ),
//                           ],
//                         ),
//                   );
//                 },
//               ),
//             ],
//           ),
//           Obx(
//             () => ListView.builder(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: FoodHistoryController.instance.foodHistory.length,
//               itemBuilder: (context, index) {
//                 final item = FoodHistoryController.instance.foodHistory[index];
//                 // Only show items from selected date
//                 if (isSameDay(item.consumedAt, selectedDate)) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.outline.withOpacity(0.2),
//                       ),
//                     ),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       title: Text(
//                         item.foodName,
//                         style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       subtitle: Text(
//                         DateFormat('h:mm a').format(item.consumedAt),
//                         style: TextStyle(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.onSurface.withOpacity(0.6),
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       trailing: Text(
//                         '${item.nutrients['Energy']?.toStringAsFixed(0) ?? 0} kcal',
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink(); // Return empty widget for non-matching dates
//               },
//             ),
//           ),
//           AddMealManuallyContainer(
//             // logic: logic
//           ),
//         ],
//       ),
//     );
//   }

//   bool isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }
// }
