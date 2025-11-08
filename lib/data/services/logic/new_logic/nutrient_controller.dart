// import 'package:eat_right/comman/models/food_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NutrientController extends GetxController {
//   static NutrientController get instance => Get.find();
//   var parsedNutrients = <Map<String, dynamic>>[].obs;
//   var goodNutrients = <Map<String, dynamic>>[].obs;
//   var badNutrients = <Map<String, dynamic>>[].obs;
//   var totalPlateNutrients = <String, dynamic>{}.obs;
//   var servingSize = 0.0.obs; // Default serving size
//   var sliderValue = 0.0.obs; // Default slider value

//   // Functions: updateSliderValue, updateNutrientsForServing, updateTotalNutrients, getCalories, getUnit, getColorForPercent

//   void updateSliderValue(double value) {
//     sliderValue.value = value;
//     if (parsedNutrients.isNotEmpty) {
//       final ratio = value / (servingSize.value == 0 ? 1 : servingSize.value);
//       updateNutrientsForServing(ratio);
//     }
//   }

//   void updateServingSize(double newSize) {
//     servingSize.value = newSize;
//   }

//   void updateNutrientsForServing(double ratio) {
//     for (var nutrient in parsedNutrients) {
//       if (nutrient.containsKey('quantity')) {
//         final quantity = nutrient['quantity'].toString().replaceAll(
//           RegExp(r'[^0-9\.]'),
//           '',
//         );
//         nutrient['quantity'] = (double.tryParse(quantity) ?? 0.0) * ratio;
//       }
//     }
//   }

//   void updateTotalNutrients(List<FoodItem> analyzedFoodItems) {
//     totalPlateNutrients.value = {
//       'calories': 0.0,
//       'protein': 0.0,
//       'carbohydrates': 0.0,
//       'fat': 0.0,
//       'fiber': 0.0,
//     };
//     for (var item in analyzedFoodItems) {
//       var itemNutrients = item.calculateTotalNutrients();
//       totalPlateNutrients.updateAll(
//         (key, value) => (value + (itemNutrients[key] ?? 0.0)),
//       );
//     }
//   }

//   double getCalories() {
//     var energyNutrient = parsedNutrients.firstWhere(
//       (nutrient) => nutrient['name'] == 'Energy',
//       orElse: () => {'quantity': '0.0'},
//     );
//     // Parse the quantity string to remove any non-numeric characters except decimal points
//     var quantity = energyNutrient['quantity'].toString().replaceAll(
//       RegExp(r'[^0-9\.]'),
//       '',
//     );
//     return double.tryParse(quantity) ?? 0.0;
//   }

//   String getUnit(String nutrient) {
//     switch (nutrient.toLowerCase()) {
//       case 'calories':
//         return ' kcal';
//       case 'protein':
//       case 'carbohydrates':
//       case 'fat':
//       case 'fiber':
//         return 'g';
//       default:
//         return '';
//     }
//   }

//   Color getColorForPercent(double percent) {
//     if (percent > 1.0) return Colors.red; // Exceeded daily value
//     if (percent > 0.8) return Colors.green; // High but not exceeded
//     if (percent > 0.6) return Colors.yellow; // Moderate
//     if (percent > 0.4) return Colors.yellow; // Low to moderate
//     return Colors.green; // Low
//   }
// }
