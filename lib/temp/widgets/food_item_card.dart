import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart'; // Import Quantity
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart'; // Import MealItem
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/nutrient_info_model.dart';
import 'package:eat_right/temp/widgets/food_nutreint_tile.dart'; // Assuming this is updated or replaced
import 'package:eat_right/utils/constants/sizes.dart'; // Use Sizes
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Updated FoodItemCard to accept MealItem
class FoodItemCard extends StatelessWidget {
  final MealItem item; // Changed parameter type to MealItem

  const FoodItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // --- Define the helper function INSIDE the build method or widget class ---
    Quantity findCoreNutrientQuantity(List<String> possibleNames) {
      final nutrientList =
          item.nutrientsForEstimatedQuantity.macroNutrients; // Search here
      for (String name in possibleNames) {
        final nameLower = name.toLowerCase();
        final nutrientDetail = nutrientList.firstWhereOrNull(
          (d) => d.name.toLowerCase() == nameLower,
        );
        if (nutrientDetail != null) {
          return Quantity(
            amount: nutrientDetail.value ?? 0,
            unit: nutrientDetail.unit ?? '',
          );
        }
      }
      // Fallback if not found
      return const Quantity(amount: 0, unit: '');
    }
    // --- End helper function definition ---

    // Get core nutrient Quantities using the local helper function
    final calories = findCoreNutrientQuantity(['calories']);
    final protein = findCoreNutrientQuantity(['protein']);
    // Handle different fat names potentially returned by AI
    final fat = findCoreNutrientQuantity(['total fat', 'fat']);
    final carbs = findCoreNutrientQuantity([
      'total carbohydrate',
      'carbohydrates',
    ]);
    final fiber = findCoreNutrientQuantity(['dietary fiber', 'fiber']);

    // ... rest of the build method remains the same ...

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace,
        vertical: Sizes.spaceBtwItems / 2,
      ), // Use Sizes
      // decoration: BoxDecoration(
      //   color: Theme.of(context).cardColor, // Use theme card color
      //   borderRadius: BorderRadius.circular(Sizes.cardRadiusMd), // Use Sizes
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            // Use a slightly different background or just padding
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),

            child: Padding(
              padding: const EdgeInsets.all(Sizes.m), // Use Sizes
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Align text top
                children: [
                  // Item Name (Allow wrapping)
                  Expanded(
                    child: Text(
                      item.itemName, // Use itemName from MealItem
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      // overflow: TextOverflow.ellipsis, // Removed ellipsis for potential wrap
                      // maxLines: 2,
                    ),
                  ),
                  // const SizedBox(width: Sizes.spaceBtwItems),
                  // Quantity Chip (Improved Styling)
                  Chip(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                    // decoration: BoxDecoration(
                    //   // color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    //   border: Border.all(
                    //     color: Theme.of(
                    //       context,
                    //     ).colorScheme.primary.withOpacity(0.5),
                    //   ),
                    //   borderRadius: BorderRadius.circular(Sizes.borderRadiusSm),
                    // ),
                    label: Text(
                      // Display quantity and unit from MealItem.estimatedQuantity
                      '${item.estimatedQuantity.amount.toStringAsFixed(item.estimatedQuantity.amount.truncateToDouble() == item.estimatedQuantity.amount ? 0 : 1)} ${item.estimatedQuantity.unit}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Edit button - Reconsider its purpose. Maybe view details instead?
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.edit_outlined, // Use outlined icon
                  //     size: 20,
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.primary.withOpacity(0.7),
                  //   ),
                  //   onPressed:
                  //       () => _showViewOnlyDialog(
                  //         context,
                  //         item,
                  //       ), // Changed dialog
                  //   // tooltip:
                  //   //     "View/Edit Details (Coming Soon)", // Update tooltip
                  //   // visualDensity: VisualDensity.compact, // Make it smaller
                  //   // padding: EdgeInsets.zero,
                  // ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: Sizes.spaceBtwItems / 2), // Reduce space
          // Nutrient grid
          Padding(
            // Add padding around GridView
            padding: const EdgeInsets.all(Sizes.m),
            child: GridView.count(
              // padding: const EdgeInsets.fromLTRB(Sizes.md, 0, Sizes.md, Sizes.md),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, // Keep 2 columns
              mainAxisSpacing: Sizes.spaceBtwItems, // Use Sizes
              crossAxisSpacing: Sizes.spaceBtwItems, // Use Sizes
              // childAspectRatio: 1.5, // Adjust aspect ratio as needed
              children: [
                // Use the fetched core nutrient Quantities
                FoodNutrientTile(
                  label: 'Calories',
                  value: calories.amount.toStringAsFixed(
                    0,
                  ), // No decimals for kcal usually
                  unit: calories.unit.isNotEmpty
                      ? calories.unit
                      : 'kcal', // Default unit
                  icon: Icons.local_fire_department_outlined,
                ),
                FoodNutrientTile(
                  label: 'Protein',
                  value: protein.amount.toStringAsFixed(1),
                  unit: protein.unit.isNotEmpty ? protein.unit : 'g',
                  icon: Icons.fitness_center_outlined,
                ),
                FoodNutrientTile(
                  label: 'Carbs', // Shorten label
                  value: carbs.amount.toStringAsFixed(1),
                  unit: carbs.unit.isNotEmpty ? carbs.unit : 'g',
                  icon: Icons.grain_outlined,
                ),
                FoodNutrientTile(
                  label: 'Fat',
                  value: fat.amount.toStringAsFixed(1),
                  unit: fat.unit.isNotEmpty ? fat.unit : 'g',
                  icon: Icons
                      .opacity_outlined, // Consider Icons.water_drop_outlined
                ),
                FoodNutrientTile(
                  label: 'Fiber',
                  value: fiber.amount.toStringAsFixed(1),
                  unit: fiber.unit.isNotEmpty ? fiber.unit : 'g',
                  icon: Icons.grass_outlined,
                ),
                // Optionally add one more key nutrient if available, e.g., Sugar
                _buildOptionalNutrientTile(
                  item.nutrientsForEstimatedQuantity,
                  'Total Sugars',
                  Icons.cake_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to find nutrient and build tile, handling potential absence
  Widget _buildOptionalNutrientTile(
    NutrientInfo info,
    String name,
    IconData icon,
  ) {
    final nameLower = name.toLowerCase();
    // Also check microNutrients list now
    final detail = [
      ...info.macroNutrients,
      ...info.microNutrients,
    ].firstWhereOrNull((d) => d.name.toLowerCase() == nameLower);

    if (detail == null || detail.value == null) {
      return SizedBox.shrink(); // Don't display if not found or value is null
    }

    return FoodNutrientTile(
      label: name, // Use original name casing
      value: detail.value!.toStringAsFixed(1),
      unit: detail.unit ?? 'g', // Default unit if missing
      icon: icon,
    );
  }

  // ... (keep _showViewOnlyDialog or remove/modify) ...
  void _showViewOnlyDialog(BuildContext context, MealItem mealItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Item Details: ${mealItem.itemName}'),
        content: SingleChildScrollView(
          // Allow scrolling if details are long
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Estimated Quantity: ${mealItem.estimatedQuantity.amount} ${mealItem.estimatedQuantity.unit}",
              ),
              const SizedBox(height: 10),
              Text(
                "Nutrients (Estimated Portion):",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              // Display more details from mealItem.nutrientsForEstimatedQuantity
              ...mealItem.nutrientsForEstimatedQuantity.macroNutrients.map(
                (n) => Text("- ${n.name}: ${n.value ?? 'N/A'} ${n.unit ?? ''}"),
              ),
              ...mealItem.nutrientsForEstimatedQuantity.microNutrients.map(
                (n) => Text("- ${n.name}: ${n.value ?? 'N/A'} ${n.unit ?? ''}"),
              ),
              // Add more details as needed (per 100g, category, etc.)
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // TextButton( // Keep edit button disabled or remove for now
          //   onPressed: null, // Disabled
          //   child: const Text('Edit (Coming Soon)'),
          // ),
        ],
      ),
    );
  }
}

// IMPORTANT: Ensure FoodNutrientTile is updated or replace its usage.
// Example structure for FoodNutrientTile if it needs creating/updating:

// import 'package:eat_right/comman/models/food_item_model.dart';
// import 'package:eat_right/data/services/logic/new_logic/analysis_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/nutrient_controller.dart';
// import 'package:eat_right/temp/widgets/food_nutreint_tile.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:flutter/material.dart';

// class FoodItemCard extends StatelessWidget {
//   final FoodItem item;

//   // final LogicController logic;

//   const FoodItemCard({
//     super.key,
//     required this.item,
//     // required this.logic
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       decoration: BoxDecoration(
//         color: SColors.borderLight,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       item.name,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                       overflow: TextOverflow.visible,
//                       softWrap: true,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.primary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '${item.quantity}${item.unit}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.edit,
//                           size: 20,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         onPressed: () => _showEditServingSizeDialog(context),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Nutrient grid
//           GridView.count(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             mainAxisSpacing: 8,
//             crossAxisSpacing: 8,
//             childAspectRatio: 3.0,
//             children: [
//               FoodNutrientTile(
//                 label: 'Calories',
//                 value:
//                     item.calculateTotalNutrients()['calories']?.toStringAsFixed(
//                       1,
//                     ) ??
//                     '0',
//                 unit: 'kcal',
//                 icon: Icons.local_fire_department_outlined,
//               ),
//               FoodNutrientTile(
//                 label: 'Protein',
//                 value:
//                     item.calculateTotalNutrients()['protein']?.toStringAsFixed(
//                       1,
//                     ) ??
//                     '0',
//                 unit: 'g',
//                 icon: Icons.fitness_center_outlined,
//               ),
//               FoodNutrientTile(
//                 label: 'Carbohydrates',
//                 value:
//                     item
//                         .calculateTotalNutrients()['carbohydrates']
//                         ?.toStringAsFixed(1) ??
//                     '0',
//                 unit: 'g',
//                 icon: Icons.grain_outlined,
//               ),
//               FoodNutrientTile(
//                 label: 'Fat',
//                 value:
//                     item.calculateTotalNutrients()['fat']?.toStringAsFixed(1) ??
//                     '0',
//                 unit: 'g',
//                 icon: Icons.opacity_outlined,
//               ),
//               FoodNutrientTile(
//                 label: 'Fiber',
//                 value:
//                     item.calculateTotalNutrients()['fiber']?.toStringAsFixed(
//                       1,
//                     ) ??
//                     '0',
//                 unit: 'g',
//                 icon: Icons.grass_outlined,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditServingSizeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             backgroundColor: Theme.of(context).colorScheme.surface,
//             title: Text(
//               'Edit Quantity',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             content: TextField(
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: 'Enter quantity in ${item.unit}',
//                 hintStyle: TextStyle(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withOpacity(0.6),
//                   fontFamily: 'Poppins',
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//                 fontFamily: 'Poppins',
//               ),
//               onChanged: (value) {
//                 double? newQuantity = double.tryParse(value);
//                 if (newQuantity != null) {
//                   item.quantity = newQuantity;
//                   NutrientController.instance.updateTotalNutrients(
//                     AnalysisController.instance.analyzedFoodItems,
//                   );
//                 }
//               },
//             ),
//             actions: [
//               TextButton(
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               TextButton(
//                 child: Text(
//                   'Save',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: () {
//                   NutrientController.instance.updateTotalNutrients(
//                     AnalysisController.instance.analyzedFoodItems,
//                   );

//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//     );
//   }
// }
