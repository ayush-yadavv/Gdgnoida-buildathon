import 'package:eat_right/data/services/logic/new_data_model/base_models/base_model.dart';

class MealComponent {
  final String referenceId; // ID of ProductModel or a generic food identifier
  final String referenceType; // 'product', 'generic_food'
  final String nameSnapshot; // Name at the time of adding to meal
  final double quantity; // Quantity of this component *in the meal definition*
  final String unit; // Unit for the quantity (e.g., "g", "serving", "piece")
  final Map<String, double>
  nutrients; // Nutrients for *this component's quantity*

  MealComponent({
    required this.referenceId,
    required this.referenceType,
    required this.nameSnapshot,
    required this.quantity,
    required this.unit,
    required this.nutrients,
  });

  Map<String, dynamic> toJson() => {
    'referenceId': referenceId,
    'referenceType': referenceType,
    'nameSnapshot': nameSnapshot,
    'quantity': quantity,
    'unit': unit,
    'nutrients': nutrients,
  };

  factory MealComponent.fromJson(Map<String, dynamic> json) {
    return MealComponent(
      referenceId: json['referenceId'] ?? '',
      referenceType: json['referenceType'] ?? 'generic_food',
      nameSnapshot: json['nameSnapshot'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'g',
      nutrients: Map<String, double>.from(json['nutrients'] ?? {}),
    );
  }
}

class FoodModel extends BaseModel {
  final String name;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final Map<String, double> nutrients;
  final double servingSize;
  final String servingUnit;
  final List<String> categories;
  final List<String> allergens;
  final bool isVerified;

  FoodModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.brand,
    this.description,
    this.imageUrl,
    required this.nutrients,
    required this.servingSize,
    required this.servingUnit,
    required this.categories,
    required this.allergens,
    this.isVerified = false,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'description': description,
    'imageUrl': imageUrl,
    'nutrients': nutrients,
    'servingSize': servingSize,
    'servingUnit': servingUnit,
    'categories': categories,
    'allergens': allergens,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
