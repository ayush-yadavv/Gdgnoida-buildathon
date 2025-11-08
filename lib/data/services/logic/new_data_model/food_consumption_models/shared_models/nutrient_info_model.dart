import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart';

class NutrientInfo {
  // V1 prompts use Lists for both macros and micros
  final List<NutrientDetail> macroNutrients;
  final List<NutrientDetail> microNutrients;

  const NutrientInfo({
    this.macroNutrients = const [], // Default to empty lists
    this.microNutrients = const [],
  });

  factory NutrientInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NutrientInfo(); // Return empty

    // Helper to parse a list of dynamics into List<NutrientDetail>
    List<NutrientDetail> parseNutrientList(List<dynamic>? list) {
      return list
              ?.map(
                (item) =>
                    NutrientDetail.fromJson(item as Map<String, dynamic>?),
              )
              .where(
                (detail) => detail.name != 'Unknown',
              ) // Filter out invalid parses
              .toList() ??
          [];
    }

    // Handle analyseFoodImageV1 micro_nutrients: {} case - treat as empty list
    List<NutrientDetail> microList;
    if (json['micro_nutrients'] is List) {
      microList = parseNutrientList(json['micro_nutrients'] as List<dynamic>?);
    } else {
      microList = []; // If it's not a list (e.g., {}), treat as empty
    }

    return NutrientInfo(
      macroNutrients: parseNutrientList(
        json['macro_nutrients'] as List<dynamic>?,
      ),
      microNutrients: microList,
    );
  }

  Map<String, dynamic> toJson() => {
    // Serialize lists back to JSON
    'macro_nutrients': macroNutrients.map((n) => n.toJson()).toList(),
    'micro_nutrients': microNutrients.map((n) => n.toJson()).toList(),
  };

  NutrientInfo copyWith({
    List<NutrientDetail>? macroNutrients,
    List<NutrientDetail>? microNutrients,
  }) {
    return NutrientInfo(
      macroNutrients: macroNutrients ?? this.macroNutrients,
      microNutrients: microNutrients ?? this.microNutrients,
    );
  }
}
