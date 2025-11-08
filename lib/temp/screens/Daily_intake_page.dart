import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:eat_right/temp/widgets/date_selector.dart';
import 'package:eat_right/temp/widgets/food_history_section.dart'; // Use updated card
import 'package:eat_right/temp/widgets/header_widget.dart'; // Assuming this uses selectedDate
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DailyIntakePage extends StatelessWidget {
  const DailyIntakePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyIntakeController controller = Get.find<DailyIntakeController>();

    // Return the RefreshIndicator + CustomScrollView directly, NOT a Scaffold
    return RefreshIndicator(
      onRefresh: () => controller.refreshWeekData(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.defaultSpace,
                      // vertical: Sizes.appBarHeight / 2,
                    ),
                    child: Obx(
                      () => HeaderCard(selectedDate: controller.selectedDate),
                    ),
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  Obx(
                    () => DateSelector(context, controller.selectedDate, (
                      DateTime newDate,
                    ) {
                      HapticFeedback.selectionClick();
                      controller.selectDate(newDate);
                    }),
                  ),
                ],
              ),
              SizedBox(height: Sizes.defaultSpace / 3),
              Divider(),
              // Content Section
              SizedBox(height: Sizes.defaultSpace / 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
                child: Column(
                  children: [
                    // --- Loading and Error Handling ---
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.currentDailyIntake == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Sizes.spaceBtwSections,
                            ),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (controller.errorMessage.isNotEmpty &&
                          controller.currentDailyIntake == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.spaceBtwSections,
                            ),
                            child: Text(
                              'Error: ${controller.errorMessage.value}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // --- Food History Summary Card ---
                    const FoodHistorySection(),
                    const SizedBox(height: Sizes.spaceBtwSections),

                    // Add some extra space at the bottom for scrolling past FABs etc.
                    // const SizedBox(height: Sizes.spaceBtwSections * 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
// import 'package:eat_right/temp/widgets/date_selector.dart';
// import 'package:eat_right/temp/widgets/detailed_nutrients_card.dart';
// import 'package:eat_right/temp/widgets/food_history_card.dart';
// import 'package:eat_right/temp/widgets/header_widget.dart';
// import 'package:eat_right/temp/widgets/macronutrien_summary_card.dart';
// import 'package:eat_right/utils/constants/sizes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DailyIntakePage extends StatelessWidget {
//   const DailyIntakePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final DailyIntakeController controller = DailyIntakeController.instance;

//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).padding.bottom + 80,
//         top: Sizes.defaultSpace,
//       ),
//       child: Column(
//         children: [
//           Obx(() => HeaderCard(selectedDate: controller.selectedDate.value)),
//           Obx(
//             () => DateSelector(context, controller.selectedDate.value, (
//               DateTime newDate,
//             ) {
//               controller.loadDailyIntake();
//             }),
//           ),
//           Obx(
//             () => MacronutrientSummaryCard(
//               context,
//               controller.currentDailyIntake.value?.totalNutrients ?? {},
//             ),
//           ),
//           Obx(
//             () => FoodHistoryCard(
//               // logic: FoodHistoryController.instance.,
//               selectedDate: controller.selectedDate.value,
//             ),
//           ),
//           // FoodHistoryCard(
//           //   // logic: FoodHistoryController.instance.,
//           //   selectedDate: controller.selectedDate.value,
//           // ),
//           DetailedNutrientsCard(
//             dailyIntake:
//                 controller.currentDailyIntake.value?.totalNutrients ?? {},
//           ),
//         ],
//       ),
//     );
//   }
// }
