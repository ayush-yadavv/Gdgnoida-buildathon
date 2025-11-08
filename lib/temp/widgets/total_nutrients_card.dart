import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart'; // For Quantity
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/nutrient_info_model.dart'; // Import NutrientInfo
import 'package:eat_right/utils/constants/sizes.dart'; // Use Sizes
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Only if needed for theme/dialogs, not core logic

class TotalNutrientsCard extends StatelessWidget {
  final NutrientInfo totalNutrients; // Accept NutrientInfo as input
  final int itemCount; // Accept item count

  const TotalNutrientsCard({
    super.key,
    required this.totalNutrients,
    required this.itemCount,
  });

  // Helper function to find a core nutrient's Quantity from the list
  Quantity _findCoreNutrient(String name) {
    final nameLower = name.toLowerCase();
    final nutrientDetail = totalNutrients.macroNutrients.firstWhereOrNull(
      (d) => d.name.toLowerCase() == nameLower,
    );
    if (nutrientDetail != null) {
      return Quantity(
        amount: nutrientDetail.value ?? 0,
        unit: nutrientDetail.unit ?? '',
      );
    }
    // Fallback for core nutrients if missing (should ideally be guaranteed by prompt)
    if (nameLower == 'calories') return const Quantity(amount: 0, unit: 'kcal');
    return const Quantity(amount: 0, unit: 'g');
  }

  // Helper function to handle name variations ('fat' vs 'total fat')
  Quantity _findCoreNutrientWithVariations(List<String> possibleNames) {
    for (String name in possibleNames) {
      final nameLower = name.toLowerCase();
      final nutrientDetail = totalNutrients.macroNutrients.firstWhereOrNull(
        (d) => d.name.toLowerCase() == nameLower,
      );
      if (nutrientDetail != null) {
        return Quantity(
          amount: nutrientDetail.value ?? 0,
          unit: nutrientDetail.unit ?? '',
        );
      }
    }
    // Fallback
    if (possibleNames.contains('calories')) {
      return const Quantity(amount: 0, unit: 'kcal');
    }
    return const Quantity(amount: 0, unit: 'g');
  }

  @override
  Widget build(BuildContext context) {
    // Extract core nutrient quantities using the helper
    final calories = _findCoreNutrient('calories');
    final protein = _findCoreNutrient('protein');
    final fat = _findCoreNutrientWithVariations(['total fat', 'fat']);
    final carbs = _findCoreNutrientWithVariations([
      'total carbohydrate',
      'carbohydrates',
    ]);
    final fiber = _findCoreNutrientWithVariations(['dietary fiber', 'fiber']);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace,
        vertical: Sizes.spaceBtwItems,
      ), // Consistent margins
      // decoration: BoxDecoration(
      //   color: Theme.of(context).cardColor, // Use theme color
      //   borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, 4),
      //     ),
      //   ],
      //   border: Border.all(
      //     color: Theme.of(context).dividerColor.withOpacity(0.5),
      //   ),
      // ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity, // Ensure header takes full width
            color: Theme.of(context).colorScheme.primary,

            child: Padding(
              padding: const EdgeInsets.all(Sizes.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meal Totals', // Updated title
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                      const SizedBox(height: Sizes.xs),
                      Text(
                        '$itemCount item${itemCount == 1 ? '' : 's'} analyzed', // Use item count passed in
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    // Icon background
                    padding: const EdgeInsets.all(Sizes.s),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded, // Changed icon
                      color: Colors.white,
                      // size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nutrient details section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Sizes.m),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface, // Match card background
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(Sizes.cardRadiusLg),
              ),
            ),
            child: Column(
              children: [
                // Use the extracted Quantity objects
                _buildNutrientRow(
                  context,
                  'Calories',
                  calories,
                  Icons.local_fire_department_outlined,
                ),
                _buildNutrientRow(
                  context,
                  'Protein',
                  protein,
                  Icons.fitness_center_outlined,
                ),
                _buildNutrientRow(
                  context,
                  'Carbs',
                  carbs,
                  Icons.grain_outlined,
                ),
                _buildNutrientRow(context, 'Fat', fat, Icons.opacity_outlined),
                _buildNutrientRow(
                  context,
                  'Fiber',
                  fiber,
                  Icons.grass_outlined,
                  isLast: true,
                ),

                // Removed the "Add to today's intake" button as logging is handled elsewhere (e.g., FAB)
                // If needed, add a button here that calls the FoodConsumptionController.logMealConsumption
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated helper to accept Quantity
  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    Quantity nutrientQuantity, // Accept Quantity object
    IconData icon, {
    bool isLast = false,
  }) {
    // Format value based on data type (e.g., 0 decimal for kcal)
    final valueString = label == 'Calories'
        ? nutrientQuantity.amount.toStringAsFixed(0)
        : nutrientQuantity.amount.toStringAsFixed(1);
    final unitString = nutrientQuantity.unit.isNotEmpty
        ? nutrientQuantity.unit
        : (label == 'Calories' ? 'kcal' : 'g'); // Add default units

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Sizes.s,
          ), // Adjusted padding
          child: Row(
            children: [
              Container(
                // Icon container
                padding: const EdgeInsets.all(Sizes.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Sizes.borderRadiusSm),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ), // Smaller icon
              ),
              const SizedBox(width: Sizes.m),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium, // Use theme style
              ),
              const Spacer(), // Pushes value to the right
              Text(
                '$valueString $unitString', // Display value and unit
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ), // Use theme style
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1, // Thinner divider
            thickness: 0.5,
          ),
      ],
    );
  }
}
// import 'package:eat_right/data/services/logic/new_logic/analysis_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/nutrient_controller.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:flutter/material.dart';

// class TotalNutrientsCard extends StatelessWidget {
//   // final LogicController logic;

//   const TotalNutrientsCard({
//     super.key,
//     // required this.logic
//   });

//   @override
//   Widget build(BuildContext context) {
//     final nutrientController = NutrientController.instance;
//     return Container(
//       margin: const EdgeInsets.all(20),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(20),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Total Nutrients',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${AnalysisController.instance.analyzedFoodItems.length} items',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.primary.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.restaurant_menu,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: SColors.borderLight,
//               borderRadius: const BorderRadius.vertical(
//                 bottom: Radius.circular(20),
//               ),
//             ),
//             child: Column(
//               children: [
//                 _buildNutrientRow(
//                   context,
//                   'Calories',
//                   nutrientController.totalPlateNutrients['calories'] ?? 0,
//                   'kcal',
//                   Icons.local_fire_department_outlined,
//                 ),
//                 _buildNutrientRow(
//                   context,
//                   'Protein',
//                   nutrientController.totalPlateNutrients['protein'] ?? 0,
//                   'g',
//                   Icons.fitness_center_outlined,
//                 ),
//                 _buildNutrientRow(
//                   context,
//                   'Carbohydrates',
//                   nutrientController.totalPlateNutrients['carbohydrates'] ?? 0,
//                   'g',
//                   Icons.grain_outlined,
//                 ),
//                 _buildNutrientRow(
//                   context,
//                   'Fat',
//                   nutrientController.totalPlateNutrients['fat'] ?? 0,
//                   'g',
//                   Icons.opacity_outlined,
//                 ),
//                 _buildNutrientRow(
//                   context,
//                   'Fiber',
//                   nutrientController.totalPlateNutrients['fiber'] ?? 0,
//                   'g',
//                   Icons.grass_outlined,
//                   isLast: true,
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     print("Add to today's intake button pressed");
//                     print(
//                       "Current total nutrients: ${nutrientController.totalPlateNutrients}",
//                     );
//                     // DailyIntakeController.instance.addToDailyIntake('food');
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Added to daily intake'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.add_circle_outline),
//                   label: const Text('Add to today\'s intake'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Theme.of(context).colorScheme.primary,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 16,
//                     ),
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNutrientRow(
//     BuildContext context,
//     String label,
//     num value,
//     String unit,
//     IconData icon, {
//     bool isLast = false,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: Theme.of(context).colorScheme.primary),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Expanded(child: Container()),
//               Text(
//                 '${value.toStringAsFixed(1)}$unit',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!isLast)
//           Divider(
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
//           ),
//       ],
//     );
//   }
// }
