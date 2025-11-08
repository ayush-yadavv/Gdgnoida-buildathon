import 'package:eat_right/data/services/logic/new_data_model/base_models/nutrient_value_model.dart';

class MacroNutrients {
  // Core five are still direct fields, but parsing ensures they exist
  final NutrientValue calories;
  final NutrientValue protein;
  final NutrientValue fat;
  final NutrientValue carbohydrates;
  final NutrientValue fiber;
  // Map for any additional macros returned
  final Map<String, NutrientValue> otherMacros;

  const MacroNutrients({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.fiber,
    this.otherMacros = const {},
  });

  // Updated fromJson
  factory MacroNutrients.fromJson(Map<String, dynamic>? json) {
    json ??= {}; // Ensure json is not null

    // Always parse the core five, NutrientValue.fromJson handles missing/null values internally
    final coreCalories = NutrientValue.fromJson(
      json['Calories'] as Map<String, dynamic>?,
    );
    final coreProtein = NutrientValue.fromJson(
      json['Protein'] as Map<String, dynamic>?,
    );
    final coreFat = NutrientValue.fromJson(
      json['Fat'] as Map<String, dynamic>?,
    ); // Assuming 'Fat' key
    final coreCarbs = NutrientValue.fromJson(
      json['Carbohydrates'] as Map<String, dynamic>?,
    ); // Assuming 'Carbohydrates' key
    final coreFiber = NutrientValue.fromJson(
      json['Fiber'] as Map<String, dynamic>?,
    );

    final other = <String, NutrientValue>{};
    final coreKeys = {'Calories', 'Protein', 'Fat', 'Carbohydrates', 'Fiber'};

    json.forEach((key, value) {
      if (!coreKeys.contains(key) && value is Map<String, dynamic>) {
        other[key] = NutrientValue.fromJson(value);
      }
    });

    return MacroNutrients(
      calories: coreCalories,
      protein: coreProtein,
      fat: coreFat,
      carbohydrates: coreCarbs,
      fiber: coreFiber,
      otherMacros: other,
    );
  }

  // Updated toJson
  Map<String, dynamic> toJson() {
    final jsonMap = <String, dynamic>{
      'Calories': calories.toJson(),
      'Protein': protein.toJson(),
      'Fat': fat.toJson(),
      'Carbohydrates': carbohydrates.toJson(),
      'Fiber': fiber.toJson(),
    };
    // Add other macros
    otherMacros.forEach((key, value) {
      jsonMap[key] = value.toJson();
    });
    return jsonMap;
  }

  // Updated copyWith
  MacroNutrients copyWith({
    NutrientValue? calories,
    NutrientValue? protein,
    NutrientValue? fat,
    NutrientValue? carbohydrates,
    NutrientValue? fiber,
    Map<String, NutrientValue>? otherMacros,
  }) {
    return MacroNutrients(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fiber: fiber ?? this.fiber,
      otherMacros: otherMacros ?? this.otherMacros,
    );
  }
}
