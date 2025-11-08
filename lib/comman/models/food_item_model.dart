class FoodItem {
  final String name;
  double quantity;
  final String unit;
  final Map<String, dynamic> nutrientsPer100g;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrientsPer100g,
  });

  Map<String, double> calculateTotalNutrients() {
    final factor = quantity / 100; // Convert to 100g basis
    return {
      'calories': nutrientsPer100g['calories'] * factor,
      'protein': nutrientsPer100g['protein'] * factor,
      'carbohydrates': nutrientsPer100g['carbohydrates'] * factor,
      'fat': nutrientsPer100g['fat'] * factor,
      'fiber': nutrientsPer100g['fiber'] * factor,
    };
  }

  void updateQuantity(double newQuantity) {
    quantity = newQuantity;
  }

  // fromJson
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      nutrientsPer100g: json['nutrientsPer100g'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'nutrientsPer100g': nutrientsPer100g,
    };
  }
}
