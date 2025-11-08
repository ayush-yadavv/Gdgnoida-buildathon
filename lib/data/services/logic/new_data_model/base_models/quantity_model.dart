class Quantity {
  final num amount;
  final String unit;

  const Quantity({required this.amount, required this.unit});

  factory Quantity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Return a default zero value quantity
      return const Quantity(amount: 0, unit: '');
    }
    return Quantity(amount: json['amount'] ?? 0, unit: json['unit'] ?? '');
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'unit': unit};

  Quantity copyWith({num? amount, String? unit}) {
    return Quantity(amount: amount ?? this.amount, unit: unit ?? this.unit);
  }
}
