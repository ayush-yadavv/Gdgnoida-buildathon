class NutrientValue {
  final num value;
  final String unit;

  const NutrientValue({required this.value, required this.unit});

  // Updated fromJson to return a non-nullable default
  factory NutrientValue.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NutrientValue(value: 0, unit: ''); // Default zero value
    }
    return NutrientValue(
      value: json['value'] ?? 0, // Default to 0 if value is null
      unit: json['unit'] ?? '', // Default to empty string if unit is null
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit};

  NutrientValue copyWith({num? value, String? unit}) {
    return NutrientValue(value: value ?? this.value, unit: unit ?? this.unit);
  }
}
