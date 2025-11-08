import 'package:flutter/foundation.dart';

class NutrientDetail {
  final String name;
  final num? value; // Keep nullable as per original
  final String? unit; // Keep nullable as per original
  final String? healthImpact; // Good | Bad | Moderate - present in V1 macros

  const NutrientDetail({
    required this.name,
    this.value,
    this.unit,
    this.healthImpact,
  });

  factory NutrientDetail.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NutrientDetail(name: 'Unknown');
    return NutrientDetail(
      name: json['name'] ?? 'Unknown',
      value: json['value'],
      unit: json['unit'],
      healthImpact: json['health_impact'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'health_impact': healthImpact,
  };

  NutrientDetail copyWith({
    String? name,
    ValueGetter<num?>? value,
    ValueGetter<String?>? unit,
    ValueGetter<String?>? healthImpact,
  }) {
    return NutrientDetail(
      name: name ?? this.name,
      value: value != null ? value() : this.value,
      unit: unit != null ? unit() : this.unit,
      healthImpact: healthImpact != null ? healthImpact() : this.healthImpact,
    );
  }
}
