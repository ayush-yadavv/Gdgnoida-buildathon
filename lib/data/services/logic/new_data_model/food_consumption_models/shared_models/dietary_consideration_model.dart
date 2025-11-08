class DietaryConsideration {
  final String dietType;
  final String suitability; // Suitable | May Contain | Not Suitable
  final String reason;

  const DietaryConsideration({
    required this.dietType,
    required this.suitability,
    required this.reason,
  });

  // ... fromJson, toJson ...

  DietaryConsideration copyWith({
    String? dietType,
    String? suitability,
    String? reason,
  }) {
    return DietaryConsideration(
      dietType: dietType ?? this.dietType,
      suitability: suitability ?? this.suitability,
      reason: reason ?? this.reason,
    );
  }

  factory DietaryConsideration.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DietaryConsideration(
        dietType: '',
        suitability: '',
        reason: '',
      );
    }
    return DietaryConsideration(
      dietType: json['diet_type'] ?? '',
      suitability: json['suitability'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'diet_type': dietType,
    'suitability': suitability,
    'reason': reason,
  };
}
