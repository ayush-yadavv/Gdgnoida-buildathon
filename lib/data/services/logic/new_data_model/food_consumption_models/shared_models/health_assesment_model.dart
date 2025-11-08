import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/dietary_consideration_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/primary_concerns_model.dart';
import 'package:flutter/foundation.dart';

class HealthAssessment {
  final num? nutritionQualityScore;
  final List<PrimaryConcern> primaryConcerns;
  final List<DietaryConsideration> dietaryConsiderations;

  const HealthAssessment({
    this.nutritionQualityScore,
    this.primaryConcerns = const [],
    this.dietaryConsiderations = const [],
  });

  // ... fromJson, toJson ...

  HealthAssessment copyWith({
    ValueGetter<num?>? nutritionQualityScore,
    List<PrimaryConcern>? primaryConcerns,
    List<DietaryConsideration>? dietaryConsiderations,
  }) {
    return HealthAssessment(
      nutritionQualityScore:
          nutritionQualityScore != null
              ? nutritionQualityScore()
              : this.nutritionQualityScore,
      primaryConcerns: primaryConcerns ?? this.primaryConcerns,
      dietaryConsiderations:
          dietaryConsiderations ?? this.dietaryConsiderations,
    );
  }

  factory HealthAssessment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthAssessment();
    return HealthAssessment(
      nutritionQualityScore: json['nutrition_quality_score'],
      primaryConcerns:
          (json['primary_concerns'] as List<dynamic>?)
              ?.map((c) => PrimaryConcern.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      dietaryConsiderations:
          (json['dietary_considerations'] as List<dynamic>?)
              ?.map(
                (d) => DietaryConsideration.fromJson(d as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'nutrition_quality_score': nutritionQualityScore,
    'primary_concerns': primaryConcerns.map((c) => c.toJson()).toList(),
    'dietary_considerations':
        dietaryConsiderations.map((d) => d.toJson()).toList(),
  };
}
