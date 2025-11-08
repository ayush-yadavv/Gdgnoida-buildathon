import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/recomendation_model.dart';

class PrimaryConcern {
  final String issue;
  final String explanation;
  final List<Recommendation> recommendations;

  const PrimaryConcern({
    required this.issue,
    required this.explanation,
    this.recommendations = const [],
  });

  // ... fromJson, toJson ...

  PrimaryConcern copyWith({
    String? issue,
    String? explanation,
    List<Recommendation>? recommendations,
  }) {
    return PrimaryConcern(
      issue: issue ?? this.issue,
      explanation: explanation ?? this.explanation,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  factory PrimaryConcern.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PrimaryConcern(issue: '', explanation: '');
    return PrimaryConcern(
      issue: json['issue'] ?? '',
      explanation: json['explanation'] ?? '',
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((r) => Recommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'issue': issue,
    'explanation': explanation,
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
  };
}
