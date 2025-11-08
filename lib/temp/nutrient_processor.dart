class NutrientProcessor {
  static Map<String, dynamic> processNutrients(Map<String, dynamic> data) {
    return {
      'calories': data['calories'] ?? 0,
      'protein': data['protein']?['value'] ?? 0,
      'carbohydrates': data['carbohydrates']?['value'] ?? 0,
      'fat': data['fat']?['value'] ?? 0,
      'fiber': data['fiber']?['value'] ?? 0,
    };
  }
}
