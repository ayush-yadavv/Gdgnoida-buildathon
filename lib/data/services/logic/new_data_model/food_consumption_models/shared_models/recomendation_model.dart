class Recommendation {
  final String food;
  final String quantity;
  final String reasoning;

  const Recommendation({
    required this.food,
    required this.quantity,
    required this.reasoning,
  });

  // ... fromJson, toJson ...

  Recommendation copyWith({String? food, String? quantity, String? reasoning}) {
    return Recommendation(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      reasoning: reasoning ?? this.reasoning,
    );
  }

  factory Recommendation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Recommendation(food: '', quantity: '', reasoning: '');
    }
    return Recommendation(
      food: json['food'] ?? '',
      quantity: json['quantity'] ?? '',
      reasoning: json['reasoning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'food': food,
    'quantity': quantity,
    'reasoning': reasoning,
  };
}
