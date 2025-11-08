// lib/data/services/logic/new_data_model/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Or your DB import
import 'package:eat_right/data/services/logic/new_data_model/base_models/base_model.dart';

class ProductModel extends BaseModel {
  final String name;
  // final String? brand;
  // final String? description;
  final String? imageUrl; // URL of the product image
  final double servingSizeValue; // e.g., 30
  final String servingSizeUnit; // e.g., "g", "ml", "piece", "cup"
  final Map<String, double> nutrientsPerServing; // Nutrients for ONE serving
  final List<String> categories;
  final List<String> allergens;
  // final String? barcode; // UPC/EAN code if available
  final String source; // "label_scan", "usda", "openfoodfacts", "user_created"
  final bool isVerified; // Has this been manually verified?
  final Map<String, dynamic>?
  metadata; // For extra source-specific data (AI results, etc.)

  ProductModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.servingSizeValue,
    required this.servingSizeUnit,
    required this.nutrientsPerServing,
    required this.source,
    // this.brand,
    this.imageUrl,
    // this.description,
    required this.categories,
    required this.allergens,
    // this.barcode,
    // required this.dataSource,
    this.isVerified = false,
    this.metadata,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // 'brand': brand,
    // 'description': description,
    'imageUrl': imageUrl,
    'servingSizeValue': servingSizeValue,
    'servingSizeUnit': servingSizeUnit,
    'nutrientsPerServing': nutrientsPerServing,
    'categories': categories,
    'allergens': allergens,
    // 'barcode': barcode,
    'source': source,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Add fromJson factory constructor based on your database (e.g., Firestore snapshot)
  factory ProductModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      name: data['name'] ?? '',
      // brand: data['brand'],
      // description: data['description'],
      imageUrl: data['imageUrl'],
      servingSizeValue: (data['servingSizeValue'] as num?)?.toDouble() ?? 0.0,
      servingSizeUnit: data['servingSizeUnit'] ?? 'g',
      nutrientsPerServing: Map<String, double>.from(
        data['nutrientsPerServing'] ?? {},
      ),
      categories: List<String>.from(data['categories'] ?? []),
      allergens: List<String>.from(data['allergens'] ?? []),
      // barcode: data['barcode'],
      source: data['source'] ?? 'unknown',
      isVerified: data['isVerified'] ?? false,
    );
  }
}
