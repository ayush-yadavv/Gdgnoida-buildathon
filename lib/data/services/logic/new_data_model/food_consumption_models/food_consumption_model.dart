// lib/data/models/food_consumption_model.dart

import 'package:eat_right/data/services/logic/new_data_model/base_models/base_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart'; // Adjust import path as needed
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum ConsumptionSourceType { meal, product, manual }

// --- ConsumedItem class remains the same ---
@immutable
class ConsumedItem {
  final String name;
  final Quantity quantityConsumed;
  final Quantity calories;
  final Quantity protein;
  final Quantity fat;
  final Quantity carbohydrates;
  final Quantity fiber;
  final Map<String, Quantity> otherConsumedMacros;

  static const Quantity _defaultQuantity = Quantity(amount: 0, unit: '');

  const ConsumedItem({
    required this.name,
    required this.quantityConsumed,
    this.calories = _defaultQuantity,
    this.protein = _defaultQuantity,
    this.fat = _defaultQuantity,
    this.carbohydrates = _defaultQuantity,
    this.fiber = _defaultQuantity,
    this.otherConsumedMacros = const {},
  });

  // ... fromMealItem, fromProductAnalysis factories ...
  // ... toJson, fromJson, copyWith ...
  // ** REVISED factory from MealItem **
  factory ConsumedItem.fromMealItem(MealItem item) {
    // Get the nutrient lists for the estimated quantity
    final estimatedMacros =
        item
            .nutrientsForEstimatedQuantity
            .macroNutrients; // This is List<NutrientDetail>
    final estimatedMicros =
        item
            .nutrientsForEstimatedQuantity
            .microNutrients; // Also List<NutrientDetail>

    Quantity coreCalories = _defaultQuantity;
    Quantity coreProtein = _defaultQuantity;
    Quantity coreFat = _defaultQuantity;
    Quantity coreCarbs = _defaultQuantity;
    Quantity coreFiber = _defaultQuantity;
    final Map<String, Quantity> others = {};

    // Combine macros and micros for easier processing if needed, or process separately
    final allNutrients = [...estimatedMacros, ...estimatedMicros];

    final coreNamesMapping = {
      'calories':
          (NutrientDetail d) =>
              coreCalories = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'protein':
          (NutrientDetail d) =>
              coreProtein = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'total fat':
          (NutrientDetail d) =>
              coreFat = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'fat':
          (NutrientDetail d) =>
              coreFat = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'total carbohydrate':
          (NutrientDetail d) =>
              coreCarbs = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'carbohydrates':
          (NutrientDetail d) =>
              coreCarbs = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'dietary fiber':
          (NutrientDetail d) =>
              coreFiber = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
      'fiber':
          (NutrientDetail d) =>
              coreFiber = Quantity(amount: d.value ?? 0, unit: d.unit ?? ''),
    };

    for (var detail in allNutrients) {
      final nameLower = detail.name.toLowerCase();
      final action = coreNamesMapping[nameLower];
      if (action != null) {
        action(detail);
      } else {
        // Add to others map if it's not a core nutrient
        others[detail.name] = Quantity(
          amount: detail.value ?? 0,
          unit: detail.unit ?? '',
        );
      }
    }

    return ConsumedItem(
      name: item.itemName,
      quantityConsumed: item.estimatedQuantity,
      calories: coreCalories,
      protein: coreProtein,
      fat: coreFat,
      carbohydrates: coreCarbs,
      fiber: coreFiber,
      otherConsumedMacros: others,
    );
  }

  // ** REVISED factory from ProductAnalysis **
  factory ConsumedItem.fromProductAnalysis(
    ProductAnalysisModel analysis, {
    required double servingsConsumed,
  }) {
    final label = analysis.nutritionLabel;
    final servingSizeValue = label.servingSize?.value ?? 1.0;
    final servingUnit = label.servingSize?.unit ?? 'serving';

    // The source lists are already NutrientDetail in the refactored model
    final allNutrientsDetails = [
      ...label.macroNutrients,
      ...label.microNutrients,
    ];

    Quantity coreCalories = _defaultQuantity;
    Quantity coreProtein = _defaultQuantity;
    Quantity coreFat = _defaultQuantity;
    Quantity coreCarbs = _defaultQuantity;
    Quantity coreFiber = _defaultQuantity;
    final Map<String, Quantity> others = {};

    final coreNamesMapping = {
      'calories':
          (NutrientDetail d) =>
              coreCalories = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'protein':
          (NutrientDetail d) =>
              coreProtein = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'total fat':
          (NutrientDetail d) =>
              coreFat = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'fat':
          (NutrientDetail d) =>
              coreFat = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'total carbohydrate':
          (NutrientDetail d) =>
              coreCarbs = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'carbohydrates':
          (NutrientDetail d) =>
              coreCarbs = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'dietary fiber':
          (NutrientDetail d) =>
              coreFiber = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
      'fiber':
          (NutrientDetail d) =>
              coreFiber = Quantity(
                amount: (d.value ?? 0) * servingsConsumed,
                unit: d.unit ?? '',
              ),
    };

    for (var detail in allNutrientsDetails) {
      final nameLower = detail.name.toLowerCase();
      final action = coreNamesMapping[nameLower];
      if (action != null) {
        action(detail); // Apply scaling logic inside the mapping function
      } else {
        // Add to others map, scaling the value
        others[detail.name] = Quantity(
          amount: (detail.value ?? 0) * servingsConsumed,
          unit: detail.unit ?? '',
        );
      }
    }

    return ConsumedItem(
      name: analysis.productDetails.fullname,
      quantityConsumed: Quantity(
        amount: servingSizeValue * servingsConsumed,
        unit: servingUnit,
      ),
      calories: coreCalories,
      protein: coreProtein,
      fat: coreFat,
      carbohydrates: coreCarbs,
      fiber: coreFiber,
      otherConsumedMacros: others,
    );
  }

  // --- toJson, fromJson, copyWith remain the same as previous version ---
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantityConsumed': quantityConsumed.toJson(),
    'calories': calories.toJson(),
    'protein': protein.toJson(),
    'fat': fat.toJson(),
    'carbohydrates': carbohydrates.toJson(),
    'fiber': fiber.toJson(),
    'otherConsumedMacros': otherConsumedMacros.map(
      (k, v) => MapEntry(k, v.toJson()),
    ),
  };

  factory ConsumedItem.fromJson(Map<String, dynamic> json) {
    Map<String, Quantity> othersMap = {};
    if (json['otherConsumedMacros'] is Map) {
      (json['otherConsumedMacros'] as Map).forEach((key, value) {
        if (key is String && value is Map<String, dynamic>) {
          othersMap[key] = Quantity.fromJson(value);
        }
      });
    }

    return ConsumedItem(
      name: json['name'] ?? 'Unknown Item',
      quantityConsumed: Quantity.fromJson(
        json['quantityConsumed'] as Map<String, dynamic>?,
      ),
      calories: Quantity.fromJson(json['calories'] as Map<String, dynamic>?),
      protein: Quantity.fromJson(json['protein'] as Map<String, dynamic>?),
      fat: Quantity.fromJson(json['fat'] as Map<String, dynamic>?),
      carbohydrates: Quantity.fromJson(
        json['carbohydrates'] as Map<String, dynamic>?,
      ),
      fiber: Quantity.fromJson(json['fiber'] as Map<String, dynamic>?),
      otherConsumedMacros: othersMap,
    );
  }

  ConsumedItem copyWith({
    String? name,
    Quantity? quantityConsumed,
    Quantity? calories,
    Quantity? protein,
    Quantity? fat,
    Quantity? carbohydrates,
    Quantity? fiber,
    Map<String, Quantity>? otherConsumedMacros,
  }) {
    return ConsumedItem(
      name: name ?? this.name,
      quantityConsumed: quantityConsumed ?? this.quantityConsumed,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fiber: fiber ?? this.fiber,
      otherConsumedMacros: otherConsumedMacros ?? this.otherConsumedMacros,
    );
  }
}

@immutable
class FoodConsumptionModel extends BaseModel {
  final String userId; // <-- Added userId field
  final ConsumptionSourceType sourceType;
  final String sourceName;
  final List<ConsumedItem> consumedItems;
  final DateTime consumedAt;
  final String? imageUrl;

  // Aggregated totals
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbohydrates;
  final double totalFiber;

  // Updated private constructor
  FoodConsumptionModel._({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId, // <-- Initialize userId
    required this.consumedAt,
    required this.sourceType,
    required this.sourceName,
    required this.consumedItems,
    this.imageUrl,
  }) : totalCalories = consumedItems.fold(
         0.0,
         (sum, item) => sum + item.calories.amount.toDouble(),
       ),
       totalProtein = consumedItems.fold(
         0.0,
         (sum, item) => sum + item.protein.amount.toDouble(),
       ),
       totalFat = consumedItems.fold(
         0.0,
         (sum, item) => sum + item.fat.amount.toDouble(),
       ),
       totalCarbohydrates = consumedItems.fold(
         0.0,
         (sum, item) => sum + item.carbohydrates.amount.toDouble(),
       ),
       totalFiber = consumedItems.fold(
         0.0,
         (sum, item) => sum + item.fiber.amount.toDouble(),
       );

  // --- Factory Constructors ---

  factory FoodConsumptionModel.create({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    required String userId, // <-- Required userId
    DateTime? consumedAt,
    required ConsumptionSourceType sourceType,
    required String sourceName,
    required List<ConsumedItem> consumedItems,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    final creationTime = createdAt ?? now;
    final consumptionTime = consumedAt ?? creationTime;
    return FoodConsumptionModel._(
      id: id ?? Uuid().v4(),
      createdAt: creationTime,
      updatedAt: updatedAt ?? creationTime,
      userId: userId, // <-- Assign userId
      consumedAt: consumptionTime,
      sourceType: sourceType,
      sourceName: sourceName,
      consumedItems: consumedItems,
      imageUrl: imageUrl,
    );
  }

  // Needs userId when creating from analysis
  factory FoodConsumptionModel.fromMealAnalysis(
    MealAnalysisModel analysis, {
    String? id,
    DateTime? timestamp,
    required String userId, // <-- Required userId
    DateTime? consumedAt,
  }) {
    final items =
        analysis.items
            .map((mealItem) => ConsumedItem.fromMealItem(mealItem))
            .toList();
    final now = DateTime.now();
    final recordTime = timestamp ?? now;
    final consumptionTime = consumedAt ?? recordTime;

    return FoodConsumptionModel._(
      id: id ?? Uuid().v4(),
      createdAt: recordTime,
      updatedAt: recordTime,
      userId: userId, // <-- Assign userId
      consumedAt: consumptionTime,
      sourceType: ConsumptionSourceType.meal,
      sourceName: analysis.mealDetails.nameSuggestion ?? 'Analyzed Meal',
      consumedItems: items,
      imageUrl: analysis.frontImageUrl,
    );
  }

  // Needs userId when creating from analysis
  factory FoodConsumptionModel.fromProductAnalysis(
    ProductAnalysisModel analysis, {
    String? id,
    DateTime? timestamp,
    required String userId, // <-- Required userId
    DateTime? consumedAt,
    required double servingsConsumed,
  }) {
    // ... (validations remain the same) ...
    if (servingsConsumed <= 0) {
      throw ArgumentError("Servings consumed must be positive.");
    }
    if (analysis.nutritionLabel.servingSize?.value == null ||
        analysis.nutritionLabel.servingSize!.value! <= 0) {
      throw ArgumentError(
        "Cannot calculate consumption without a valid serving size.",
      );
    }

    final item = ConsumedItem.fromProductAnalysis(
      analysis,
      servingsConsumed: servingsConsumed,
    );
    final now = DateTime.now();
    final recordTime = timestamp ?? now;
    final consumptionTime = consumedAt ?? recordTime;

    return FoodConsumptionModel._(
      id: id ?? Uuid().v4(),
      createdAt: recordTime,
      updatedAt: recordTime,
      userId: userId, // <-- Assign userId
      consumedAt: consumptionTime,
      sourceType: ConsumptionSourceType.product,
      sourceName: analysis.productDetails.fullname,
      consumedItems: [item],
      imageUrl: analysis.frontImageUrl,
    );
  }

  // --- JSON Serialization ---
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'userId': userId, // <-- Serialize userId
    'consumedAt': consumedAt.toIso8601String(),
    'sourceType': sourceType.name,
    'sourceName': sourceName,
    'consumedItems': consumedItems.map((item) => item.toJson()).toList(),
    'imageUrl': imageUrl,
  };

  factory FoodConsumptionModel.fromJson(Map<String, dynamic> json) {
    final sourceTypeString = json['sourceType'] as String?;
    final sourceType = ConsumptionSourceType.values.firstWhere(
      (e) => e.name == sourceTypeString,
      orElse: () => ConsumptionSourceType.manual,
    );
    final now = DateTime.now();
    final createdAtParsed = DateTime.tryParse(json['createdAt'] ?? '') ?? now;
    final consumedAtParsed =
        DateTime.tryParse(json['consumedAt'] ?? '') ?? createdAtParsed;

    return FoodConsumptionModel._(
      id: json['id'] ?? Uuid().v4(),
      createdAt: createdAtParsed,
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? createdAtParsed,
      userId:
          json['userId'] ?? '', // <-- Parse userId (provide default if missing)
      consumedAt: consumedAtParsed,
      sourceType: sourceType,
      sourceName: json['sourceName'] ?? 'Unknown Source',
      consumedItems:
          (json['consumedItems'] as List<dynamic>?)
              ?.map(
                (item) => ConsumedItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      imageUrl: json['imageUrl'],
    );
  }

  // --- CopyWith Method ---
  FoodConsumptionModel copyWith({
    // id and userId typically shouldn't be changed via copyWith
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? consumedAt,
    ConsumptionSourceType? sourceType,
    String? sourceName,
    List<ConsumedItem>? consumedItems,
    ValueGetter<String?>? imageUrl,
  }) {
    final newUpdatedAt = updatedAt ?? DateTime.now();
    return FoodConsumptionModel._(
      id: id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: newUpdatedAt,
      userId: userId, // Keep original userId
      consumedAt: consumedAt ?? this.consumedAt,
      sourceType: sourceType ?? this.sourceType,
      sourceName: sourceName ?? this.sourceName,
      consumedItems: consumedItems ?? this.consumedItems,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
    );
  }
} // Reminder: Adjust import paths for BaseModel and Quantity if they moved
/*
// lib/data/services/logic/new_data_model/shared_models/base_model.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class BaseModel { ... }

// lib/data/services/logic/new_data_model/base_models/quantity_model.dart
import 'package:flutter/foundation.dart';

@immutable
class Quantity { ... }
*/
// // lib/data/models/food_consumption_model.dart

// import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/shared_models/base_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:uuid/uuid.dart';

// enum ConsumptionSourceType { meal, product, manual }

// @immutable
// class ConsumedItem {
//   final String name;
//   final Quantity quantityConsumed; // e.g., Quantity(amount: 150, unit: 'g')

//   // Store core nutrients as Quantity
//   final Quantity calories; // e.g., Quantity(amount: 280, unit: 'kcal')
//   final Quantity protein; // e.g., Quantity(amount: 35, unit: 'g')
//   final Quantity fat; // e.g., Quantity(amount: 12.5, unit: 'g')
//   final Quantity carbohydrates; // e.g., Quantity(amount: 0, unit: 'g')
//   final Quantity fiber; // e.g., Quantity(amount: 0, unit: 'g')

//   // Store other consumed macros as Quantity map
//   final Map<String, Quantity> otherConsumedMacros;

//   // Default Quantity constant for initialization
//   static const Quantity _defaultQuantity = Quantity(amount: 0, unit: '');

//   const ConsumedItem({
//     required this.name,
//     required this.quantityConsumed,
//     this.calories = _defaultQuantity, // Default to zero quantity
//     this.protein = _defaultQuantity,
//     this.fat = _defaultQuantity,
//     this.carbohydrates = _defaultQuantity,
//     this.fiber = _defaultQuantity,
//     this.otherConsumedMacros = const {},
//   });

//   // Updated factory from MealItem
//   factory ConsumedItem.fromMealItem(MealItem item) {
//     final estimatedMacros = item.nutrientsForEstimatedQuantity.macroNutrients;
//     final otherMacrosMap = <String, Quantity>{};

//     // Convert NutrientValue to Quantity for other macros
//     estimatedMacros.otherMacros.forEach((key, nutrientValue) {
//       otherMacrosMap[key] = Quantity(
//         amount: nutrientValue.value,
//         unit: nutrientValue.unit,
//       );
//     });

//     // Convert NutrientValue to Quantity for core macros
//     return ConsumedItem(
//       name: item.itemName,
//       quantityConsumed: item.estimatedQuantity,
//       calories: Quantity(
//         amount: estimatedMacros.calories.value,
//         unit: estimatedMacros.calories.unit,
//       ),
//       protein: Quantity(
//         amount: estimatedMacros.protein.value,
//         unit: estimatedMacros.protein.unit,
//       ),
//       fat: Quantity(
//         amount: estimatedMacros.fat.value,
//         unit: estimatedMacros.fat.unit,
//       ),
//       carbohydrates: Quantity(
//         amount: estimatedMacros.carbohydrates.value,
//         unit: estimatedMacros.carbohydrates.unit,
//       ),
//       fiber: Quantity(
//         amount: estimatedMacros.fiber.value,
//         unit: estimatedMacros.fiber.unit,
//       ),
//       otherConsumedMacros: otherMacrosMap,
//     );
//   }

//   // Updated factory from ProductAnalysis
//   factory ConsumedItem.fromProductAnalysis(
//     ProductAnalysisModel analysis, {
//     required double servingsConsumed,
//   }) {
//     final label = analysis.nutritionLabel;
//     final servingSizeValue = label.servingSize?.value ?? 1.0;
//     final servingUnit =
//         label.servingSize?.unit ??
//         'serving'; // Base unit for consumption quantity

//     final allNutrientsDetails = [
//       ...?label.macroNutrients,
//       ...?label.microNutrients,
//     ];

//     final coreMap = <String, Quantity>{};
//     final othersMap = <String, Quantity>{};
//     final coreNamesLower = {
//       'calories',
//       'protein',
//       'total fat',
//       'fat',
//       'total carbohydrate',
//       'carbohydrates',
//       'dietary fiber',
//       'fiber',
//     };

//     for (var detail in allNutrientsDetails) {
//       final valuePerServing = detail.value ?? 0; // Keep as num
//       final unit = detail.unit ?? '';
//       final consumedAmount =
//           valuePerServing * servingsConsumed; // Calculate consumed amount
//       final consumedQuantity = Quantity(
//         amount: consumedAmount,
//         unit: unit,
//       ); // Create Quantity object
//       final nameLower = detail.name.toLowerCase();

//       if (coreNamesLower.contains(nameLower)) {
//         String coreKey = nameLower;
//         if (nameLower == 'total fat') coreKey = 'fat';
//         if (nameLower == 'total carbohydrate') coreKey = 'carbohydrates';
//         if (nameLower == 'dietary fiber') coreKey = 'fiber';
//         coreMap[coreKey] = consumedQuantity; // Store Quantity object
//       } else {
//         othersMap[detail.name] = consumedQuantity; // Store Quantity object
//       }
//     }

//     // Helper to get Quantity or default zero Quantity
//     Quantity getCoreQuantity(String key) =>
//         coreMap[key] ?? const Quantity(amount: 0, unit: '');

//     return ConsumedItem(
//       name: analysis.productDetails.fullname,
//       quantityConsumed: Quantity(
//         amount: servingSizeValue * servingsConsumed,
//         unit: servingUnit,
//       ),
//       calories: getCoreQuantity('calories'),
//       protein: getCoreQuantity('protein'),
//       fat: getCoreQuantity('fat'),
//       carbohydrates: getCoreQuantity('carbohydrates'),
//       fiber: getCoreQuantity('fiber'),
//       otherConsumedMacros: othersMap,
//     );
//   }

//   // Updated toJson
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'quantityConsumed': quantityConsumed.toJson(),
//     'calories': calories.toJson(), // Serialize Quantity
//     'protein': protein.toJson(),
//     'fat': fat.toJson(),
//     'carbohydrates': carbohydrates.toJson(),
//     'fiber': fiber.toJson(),
//     // Serialize map of Quantities
//     'otherConsumedMacros': otherConsumedMacros.map(
//       (k, v) => MapEntry(k, v.toJson()),
//     ),
//   };

//   // Updated fromJson
//   factory ConsumedItem.fromJson(Map<String, dynamic> json) {
//     Map<String, Quantity> othersMap = {};
//     if (json['otherConsumedMacros'] is Map) {
//       (json['otherConsumedMacros'] as Map).forEach((key, value) {
//         if (key is String && value is Map<String, dynamic>) {
//           // Parse inner map into Quantity
//           othersMap[key] = Quantity.fromJson(value);
//         }
//       });
//     }

//     return ConsumedItem(
//       name: json['name'] ?? 'Unknown Item',
//       quantityConsumed: Quantity.fromJson(
//         json['quantityConsumed'] as Map<String, dynamic>?,
//       ),
//       calories: Quantity.fromJson(
//         json['calories'] as Map<String, dynamic>?,
//       ), // Parse Quantity
//       protein: Quantity.fromJson(json['protein'] as Map<String, dynamic>?),
//       fat: Quantity.fromJson(json['fat'] as Map<String, dynamic>?),
//       carbohydrates: Quantity.fromJson(
//         json['carbohydrates'] as Map<String, dynamic>?,
//       ),
//       fiber: Quantity.fromJson(json['fiber'] as Map<String, dynamic>?),
//       otherConsumedMacros: othersMap,
//     );
//   }

//   // Updated copyWith
//   ConsumedItem copyWith({
//     String? name,
//     Quantity? quantityConsumed,
//     Quantity? calories, // Use Quantity type
//     Quantity? protein,
//     Quantity? fat,
//     Quantity? carbohydrates,
//     Quantity? fiber,
//     Map<String, Quantity>? otherConsumedMacros, // Use Quantity type
//   }) {
//     return ConsumedItem(
//       name: name ?? this.name,
//       quantityConsumed: quantityConsumed ?? this.quantityConsumed,
//       calories: calories ?? this.calories,
//       protein: protein ?? this.protein,
//       fat: fat ?? this.fat,
//       carbohydrates: carbohydrates ?? this.carbohydrates,
//       fiber: fiber ?? this.fiber,
//       otherConsumedMacros: otherConsumedMacros ?? this.otherConsumedMacros,
//     );
//   }
// }

// class FoodConsumptionModel extends BaseModel {
//   final ConsumptionSourceType sourceType;
//   final String sourceName;
//   final List<ConsumedItem> consumedItems;

//   // Aggregated totals - calculate numeric sum from Quantity amounts
//   // Note: Assumes units are consistent or aggregation logic handles conversion if needed.
//   // For simplicity here, we sum the 'amount' directly.
//   final double totalCalories;
//   final double totalProtein;
//   final double totalFat;
//   final double totalCarbohydrates;
//   final double totalFiber;

//   // Updated private constructor to sum Quantity amounts
//   FoodConsumptionModel._({
//     required super.id,
//     required super.createdAt,
//     required super.updatedAt,
//     required this.sourceType,
//     required this.sourceName,
//     required this.consumedItems,
//   }) : totalCalories = consumedItems.fold(
//          0.0,
//          (sum, item) => sum + item.calories.amount.toDouble(),
//        ),
//        totalProtein = consumedItems.fold(
//          0.0,
//          (sum, item) => sum + item.protein.amount.toDouble(),
//        ),
//        totalFat = consumedItems.fold(
//          0.0,
//          (sum, item) => sum + item.fat.amount.toDouble(),
//        ),
//        totalCarbohydrates = consumedItems.fold(
//          0.0,
//          (sum, item) => sum + item.carbohydrates.amount.toDouble(),
//        ),
//        totalFiber = consumedItems.fold(
//          0.0,
//          (sum, item) => sum + item.fiber.amount.toDouble(),
//        );

//   // --- Factory Constructors (No change needed, they call updated ConsumedItem factories) ---
//   factory FoodConsumptionModel.create({
//     String? id, // Allow providing ID, default to new UUID
//     DateTime? createdAt, // Allow providing createdAt
//     DateTime? updatedAt, // Allow providing updatedAt
//     required ConsumptionSourceType sourceType,
//     required String sourceName,
//     required List<ConsumedItem> consumedItems,
//   }) {
//     final now = DateTime.now();
//     final creationTime = createdAt ?? now;
//     return FoodConsumptionModel._(
//       id: id ?? Uuid().v4(),
//       createdAt: creationTime,
//       // By default, updatedAt is the same as createdAt initially
//       updatedAt: updatedAt ?? creationTime,
//       sourceType: sourceType,
//       sourceName: sourceName,
//       consumedItems: consumedItems,
//     );
//   }

//   // Create from MealAnalysis
//   factory FoodConsumptionModel.fromMealAnalysis(
//     MealAnalysisModel analysis, {
//     String? id,
//     DateTime? timestamp,
//   }) {
//     // This now correctly uses the updated ConsumedItem.fromMealItem
//     final items =
//         analysis.items
//             .map((mealItem) => ConsumedItem.fromMealItem(mealItem))
//             .toList();
//     final now = DateTime.now();
//     final creationTime = timestamp ?? now;
//     return FoodConsumptionModel._(
//       id: id ?? Uuid().v4(),
//       createdAt: creationTime,
//       updatedAt: creationTime, // Initially same as creation
//       sourceType: ConsumptionSourceType.meal,
//       sourceName: analysis.mealDetails.nameSuggestion ?? 'Analyzed Meal',
//       consumedItems: items,
//     );
//   }

//   // Create from ProductAnalysis (requires servings consumed)
//   factory FoodConsumptionModel.fromProductAnalysis(
//     ProductAnalysisModel analysis, {
//     String? id,
//     DateTime? timestamp,
//     required double servingsConsumed,
//   }) {
//     if (servingsConsumed <= 0) {
//       throw ArgumentError("Servings consumed must be positive.");
//     }
//     if (analysis.nutritionLabel.servingSize?.value == null ||
//         analysis.nutritionLabel.servingSize!.value! <= 0) {
//       throw ArgumentError(
//         "Cannot calculate consumption without a valid serving size in the product analysis.",
//       );
//     }

//     // This now correctly uses the updated ConsumedItem.fromProductAnalysis
//     final item = ConsumedItem.fromProductAnalysis(
//       analysis,
//       servingsConsumed: servingsConsumed,
//     );
//     final now = DateTime.now();
//     final creationTime = timestamp ?? now;
//     return FoodConsumptionModel._(
//       id: id ?? Uuid().v4(),
//       createdAt: creationTime,
//       updatedAt: creationTime, // Initially same as creation
//       sourceType: ConsumptionSourceType.product,
//       sourceName: analysis.productDetails.fullname,
//       consumedItems: [item],
//     );
//   }

//   // --- JSON Serialization (Uses updated ConsumedItem.toJson) ---
//   @override
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//     'sourceType': sourceType.name,
//     'sourceName': sourceName,
//     'consumedItems': consumedItems.map((item) => item.toJson()).toList(),
//   };

//   // --- fromJson (Uses updated ConsumedItem.fromJson) ---
//   factory FoodConsumptionModel.fromJson(Map<String, dynamic> json) {
//     final sourceTypeString = json['sourceType'] as String?;
//     final sourceType = ConsumptionSourceType.values.firstWhere(
//       (e) => e.name == sourceTypeString,
//       orElse: () => ConsumptionSourceType.manual,
//     );
//     final now = DateTime.now();

//     return FoodConsumptionModel._(
//       id: json['id'] ?? Uuid().v4(),
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? now,
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? now,
//       sourceType: sourceType,
//       sourceName: json['sourceName'] ?? 'Unknown Source',
//       consumedItems:
//           (json['consumedItems'] as List<dynamic>?)
//               ?.map(
//                 (item) => ConsumedItem.fromJson(item as Map<String, dynamic>),
//               )
//               .toList() ??
//           [],
//     );
//   }

//   // --- CopyWith Method (No change needed) ---
//   FoodConsumptionModel copyWith({
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     ConsumptionSourceType? sourceType,
//     String? sourceName,
//     List<ConsumedItem>? consumedItems,
//   }) {
//     final newUpdatedAt = updatedAt ?? DateTime.now();

//     return FoodConsumptionModel._(
//       id: id,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: newUpdatedAt,
//       sourceType: sourceType ?? this.sourceType,
//       sourceName: sourceName ?? this.sourceName,
//       consumedItems: consumedItems ?? this.consumedItems,
//     );
//   }
// }

// // // lib/data/models/food_consumption_model.dart

// // import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart';
// // import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart';
// // import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
// // import 'package:eat_right/data/services/logic/new_data_model/shared_models/base_model.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:uuid/uuid.dart';

// // enum ConsumptionSourceType { meal, product, manual }

// // @immutable
// // class ConsumedItem {
// //   final String name; // Meal item name or Product name
// //   final Quantity quantityConsumed;
// //   // Store core nutrients directly for the consumed quantity
// //   final double calories;
// //   final double protein;
// //   final double fat;
// //   final double carbohydrates;
// //   final double fiber;
// //   // Store other consumed macros
// //   final Map<String, double> otherConsumedMacros;

// //   const ConsumedItem({
// //     required this.name,
// //     required this.quantityConsumed,
// //     required this.calories,
// //     required this.protein,
// //     required this.fat,
// //     required this.carbohydrates,
// //     required this.fiber,
// //     this.otherConsumedMacros = const {}, // Initialize to empty
// //   });

// //   // Updated factory from MealItem
// //   factory ConsumedItem.fromMealItem(MealItem item) {
// //     final estimatedMacros = item.nutrientsForEstimatedQuantity.macroNutrients;
// //     final otherMacrosMap = <String, double>{};
// //     estimatedMacros.otherMacros.forEach((key, nutrientValue) {
// //       otherMacrosMap[key] = nutrientValue.value.toDouble();
// //     });

// //     return ConsumedItem(
// //       name: item.itemName,
// //       quantityConsumed: item.estimatedQuantity, // Defaulting to estimated
// //       calories:
// //           estimatedMacros.calories.value.toDouble(), // Access core directly
// //       protein: estimatedMacros.protein.value.toDouble(),
// //       fat: estimatedMacros.fat.value.toDouble(),
// //       carbohydrates: estimatedMacros.carbohydrates.value.toDouble(),
// //       fiber: estimatedMacros.fiber.value.toDouble(),
// //       otherConsumedMacros: otherMacrosMap, // Assign the populated map
// //     );
// //   }

// //   // Updated factory from ProductAnalysis
// //   factory ConsumedItem.fromProductAnalysis(
// //     ProductAnalysisModel analysis, {
// //     required double servingsConsumed,
// //   }) {
// //     final label = analysis.nutritionLabel;
// //     final servingSize = label.servingSize?.value ?? 1.0;
// //     final servingUnit = label.servingSize?.unit ?? 'serving';

// //     // Combine macro and micro lists for easier searching by name
// //     final allNutrientsDetails = [
// //       ...?label.macroNutrients,
// //       ...?label.microNutrients,
// //     ];

// //     final coreMap = <String, double>{};
// //     final othersMap = <String, double>{};
// //     final coreNamesLower = {
// //       'calories',
// //       'protein',
// //       'total fat',
// //       'fat',
// //       'total carbohydrate',
// //       'carbohydrates',
// //       'dietary fiber',
// //       'fiber',
// //     }; // Handle variations

// //     for (var detail in allNutrientsDetails) {
// //       final valuePerServing = (detail.value ?? 0).toDouble();
// //       final consumedValue = valuePerServing * servingsConsumed;
// //       final nameLower = detail.name.toLowerCase();

// //       if (coreNamesLower.contains(nameLower)) {
// //         // Map variations to standard keys for coreMap
// //         String coreKey = nameLower;
// //         if (nameLower == 'total fat') coreKey = 'fat';
// //         if (nameLower == 'total carbohydrate') coreKey = 'carbohydrates';
// //         if (nameLower == 'dietary fiber') coreKey = 'fiber';
// //         coreMap[coreKey] = consumedValue;
// //       } else {
// //         // Assume anything else found in the macro/micro list (that isn't core)
// //         // can be considered an "other" macro/micro for logging purposes.
// //         // If you need stricter filtering (e.g., only known macros like Sugar), add checks here.
// //         othersMap[detail.name] = consumedValue; // Use original name casing
// //       }
// //     }

// //     return ConsumedItem(
// //       name: analysis.productDetails.fullname,
// //       quantityConsumed: Quantity(
// //         amount: servingSize * servingsConsumed,
// //         unit: servingUnit,
// //       ),
// //       calories: coreMap['calories'] ?? 0.0,
// //       protein: coreMap['protein'] ?? 0.0,
// //       fat: coreMap['fat'] ?? 0.0, // Uses mapped key
// //       carbohydrates: coreMap['carbohydrates'] ?? 0.0, // Uses mapped key
// //       fiber: coreMap['fiber'] ?? 0.0, // Uses mapped key
// //       otherConsumedMacros: othersMap, // Assign other found nutrients
// //     );
// //   }

// //   // Updated toJson
// //   Map<String, dynamic> toJson() => {
// //     'name': name,
// //     'quantityConsumed': quantityConsumed.toJson(),
// //     'calories': calories,
// //     'protein': protein,
// //     'fat': fat,
// //     'carbohydrates': carbohydrates,
// //     'fiber': fiber,
// //     'otherConsumedMacros': otherConsumedMacros, // Serialize the map
// //   };

// //   // Updated fromJson
// //   factory ConsumedItem.fromJson(Map<String, dynamic> json) {
// //     // Safely parse the otherConsumedMacros map
// //     Map<String, double> othersMap = {};
// //     if (json['otherConsumedMacros'] is Map) {
// //       // Ensure keys are strings and values are doubles
// //       (json['otherConsumedMacros'] as Map).forEach((key, value) {
// //         if (key is String && value is num) {
// //           othersMap[key] = value.toDouble();
// //         }
// //       });
// //     }

// //     return ConsumedItem(
// //       name: json['name'] ?? 'Unknown Item',
// //       quantityConsumed: Quantity.fromJson(
// //         json['quantityConsumed'] as Map<String, dynamic>?,
// //       ), // Ensure type cast
// //       calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
// //       protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
// //       fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
// //       carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
// //       fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
// //       otherConsumedMacros: othersMap, // Assign parsed map
// //     );
// //   }

// //   // Updated copyWith
// //   ConsumedItem copyWith({
// //     String? name,
// //     Quantity? quantityConsumed,
// //     double? calories,
// //     double? protein,
// //     double? fat,
// //     double? carbohydrates,
// //     double? fiber,
// //     Map<String, double>? otherConsumedMacros, // Add parameter
// //   }) {
// //     return ConsumedItem(
// //       name: name ?? this.name,
// //       quantityConsumed: quantityConsumed ?? this.quantityConsumed,
// //       calories: calories ?? this.calories,
// //       protein: protein ?? this.protein,
// //       fat: fat ?? this.fat,
// //       carbohydrates: carbohydrates ?? this.carbohydrates,
// //       fiber: fiber ?? this.fiber,
// //       otherConsumedMacros:
// //           otherConsumedMacros ?? this.otherConsumedMacros, // Update
// //     );
// //   }
// // }

// // class FoodConsumptionModel extends BaseModel {
// //   final ConsumptionSourceType sourceType;
// //   final String sourceName;
// //   final List<ConsumedItem> consumedItems;

// //   // Aggregated totals - still focused on core five for simplicity at this level
// //   final double totalCalories;
// //   final double totalProtein;
// //   final double totalFat;
// //   final double totalCarbohydrates;
// //   final double totalFiber;

// //   // Private constructor remains largely the same, totals calculation unchanged
// //   FoodConsumptionModel._({
// //     required super.id,
// //     required super.createdAt,
// //     required super.updatedAt,
// //     required this.sourceType,
// //     required this.sourceName,
// //     required this.consumedItems,
// //   }) : totalCalories = consumedItems.fold(
// //          0.0,
// //          (sum, item) => sum + item.calories,
// //        ),
// //        totalProtein = consumedItems.fold(
// //          0.0,
// //          (sum, item) => sum + item.protein,
// //        ),
// //        totalFat = consumedItems.fold(0.0, (sum, item) => sum + item.fat),
// //        totalCarbohydrates = consumedItems.fold(
// //          0.0,
// //          (sum, item) => sum + item.carbohydrates,
// //        ),
// //        totalFiber = consumedItems.fold(0.0, (sum, item) => sum + item.fiber);

// //   // --- Factory Constructors (no change needed in signatures, internal calls updated) ---
// //   factory FoodConsumptionModel.create({
// //     String? id, // Allow providing ID, default to new UUID
// //     DateTime? createdAt, // Allow providing createdAt
// //     DateTime? updatedAt, // Allow providing updatedAt
// //     required ConsumptionSourceType sourceType,
// //     required String sourceName,
// //     required List<ConsumedItem> consumedItems,
// //   }) {
// //     final now = DateTime.now();
// //     final creationTime = createdAt ?? now;
// //     return FoodConsumptionModel._(
// //       id: id ?? Uuid().v4(),
// //       createdAt: creationTime,
// //       // By default, updatedAt is the same as createdAt initially
// //       updatedAt: updatedAt ?? creationTime,
// //       sourceType: sourceType,
// //       sourceName: sourceName,
// //       consumedItems: consumedItems,
// //     );
// //   }

// //   // Create from MealAnalysis
// //   factory FoodConsumptionModel.fromMealAnalysis(
// //     MealAnalysisModel analysis, {
// //     String? id,
// //     DateTime? timestamp,
// //   }) {
// //     // This now correctly uses the updated ConsumedItem.fromMealItem
// //     final items =
// //         analysis.items
// //             .map((mealItem) => ConsumedItem.fromMealItem(mealItem))
// //             .toList();
// //     final now = DateTime.now();
// //     final creationTime = timestamp ?? now;
// //     return FoodConsumptionModel._(
// //       id: id ?? Uuid().v4(),
// //       createdAt: creationTime,
// //       updatedAt: creationTime, // Initially same as creation
// //       sourceType: ConsumptionSourceType.meal,
// //       sourceName: analysis.mealDetails.nameSuggestion ?? 'Analyzed Meal',
// //       consumedItems: items,
// //     );
// //   }

// //   // Create from ProductAnalysis (requires servings consumed)
// //   factory FoodConsumptionModel.fromProductAnalysis(
// //     ProductAnalysisModel analysis, {
// //     String? id,
// //     DateTime? timestamp,
// //     required double servingsConsumed,
// //   }) {
// //     if (servingsConsumed <= 0) {
// //       throw ArgumentError("Servings consumed must be positive.");
// //     }
// //     if (analysis.nutritionLabel.servingSize?.value == null ||
// //         analysis.nutritionLabel.servingSize!.value! <= 0) {
// //       throw ArgumentError(
// //         "Cannot calculate consumption without a valid serving size in the product analysis.",
// //       );
// //     }

// //     // This now correctly uses the updated ConsumedItem.fromProductAnalysis
// //     final item = ConsumedItem.fromProductAnalysis(
// //       analysis,
// //       servingsConsumed: servingsConsumed,
// //     );
// //     final now = DateTime.now();
// //     final creationTime = timestamp ?? now;
// //     return FoodConsumptionModel._(
// //       id: id ?? Uuid().v4(),
// //       createdAt: creationTime,
// //       updatedAt: creationTime, // Initially same as creation
// //       sourceType: ConsumptionSourceType.product,
// //       sourceName: analysis.productDetails.fullname,
// //       consumedItems: [item],
// //     );
// //   }

// //   // --- JSON Serialization (toJson updated to use ConsumedItem.toJson) ---
// //   @override
// //   Map<String, dynamic> toJson() => {
// //     'id': id,
// //     'createdAt': createdAt.toIso8601String(),
// //     'updatedAt': updatedAt.toIso8601String(),
// //     'sourceType': sourceType.name,
// //     'sourceName': sourceName,
// //     'consumedItems':
// //         consumedItems
// //             .map((item) => item.toJson())
// //             .toList(), // Uses updated item.toJson()
// //   };

// //   // Updated fromJson to use ConsumedItem.fromJson
// //   factory FoodConsumptionModel.fromJson(Map<String, dynamic> json) {
// //     final sourceTypeString = json['sourceType'] as String?;
// //     final sourceType = ConsumptionSourceType.values.firstWhere(
// //       (e) => e.name == sourceTypeString,
// //       orElse: () => ConsumptionSourceType.manual,
// //     );
// //     final now = DateTime.now();

// //     return FoodConsumptionModel._(
// //       id: json['id'] ?? Uuid().v4(),
// //       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? now,
// //       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? now,
// //       sourceType: sourceType,
// //       sourceName: json['sourceName'] ?? 'Unknown Source',
// //       // Uses updated ConsumedItem.fromJson which handles otherConsumedMacros
// //       consumedItems:
// //           (json['consumedItems'] as List<dynamic>?)
// //               ?.map(
// //                 (item) => ConsumedItem.fromJson(item as Map<String, dynamic>),
// //               )
// //               .toList() ??
// //           [],
// //     );
// //   }

// //   // --- CopyWith Method (no change needed in signature, internal calls updated) ---
// //   FoodConsumptionModel copyWith({
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //     ConsumptionSourceType? sourceType,
// //     String? sourceName,
// //     List<ConsumedItem>? consumedItems,
// //   }) {
// //     final newUpdatedAt = updatedAt ?? DateTime.now();

// //     return FoodConsumptionModel._(
// //       id: id,
// //       createdAt: createdAt ?? this.createdAt,
// //       updatedAt: newUpdatedAt,
// //       sourceType: sourceType ?? this.sourceType,
// //       sourceName: sourceName ?? this.sourceName,
// //       consumedItems: consumedItems ?? this.consumedItems,
// //     );
// //   }
// // }

// // // Ensure you have the BaseModel definition somewhere accessible, e.g.:
// // // lib/data/services/logic/new_data_model/base_model.dart
// // /*
// // import 'package:flutter/foundation.dart';

// // @immutable
// // abstract class BaseModel {
// //   final String id;
// //   final DateTime createdAt;
// //   final DateTime updatedAt;

// //   const BaseModel({
// //     required this.id,
// //     required this.createdAt,
// //     required this.updatedAt,
// //   });

// //   Map<String, dynamic> toJson(); // Require subclasses to implement toJson
// // }
// // */
