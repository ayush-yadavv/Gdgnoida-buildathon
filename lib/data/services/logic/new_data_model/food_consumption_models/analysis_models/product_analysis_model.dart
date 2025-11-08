// lib/data/models/product_analysis_model.dart

import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/health_assesment_model.dart';
import 'package:flutter/foundation.dart';

// --- ImageQuality, ProductDetails, ServingSize remain the same ---
// ... (Keep existing ImageQuality, ProductDetails, ServingSize classes) ...
@immutable
class ImageQuality {
  final String? frontImage; // High | Medium | Low | Missing
  final String? labelImage; // High | Medium | Low | Missing

  const ImageQuality({this.frontImage, this.labelImage});

  // ... fromJson, toJson ...

  ImageQuality copyWith({
    ValueGetter<String?>? frontImage,
    ValueGetter<String?>? labelImage,
  }) {
    return ImageQuality(
      frontImage: frontImage != null ? frontImage() : this.frontImage,
      labelImage: labelImage != null ? labelImage() : this.labelImage,
    );
  }

  factory ImageQuality.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ImageQuality();
    return ImageQuality(
      frontImage: json['front_image'],
      labelImage: json['label_image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'front_image': frontImage,
    'label_image': labelImage,
  };
}

@immutable
class ProductDetails {
  final String fullname;
  final String? brandname;
  final String? variant;
  final String? categoryGuess;
  final Quantity? packagingSize;

  const ProductDetails({
    required this.fullname,
    this.brandname,
    this.variant,
    this.categoryGuess,
    this.packagingSize,
  });

  // ... fromJson, toJson ...

  ProductDetails copyWith({
    String? fullname,
    ValueGetter<String?>? brandname,
    ValueGetter<String?>? variant,
    ValueGetter<String?>? categoryGuess,
    ValueGetter<Quantity?>? packagingSize,
  }) {
    return ProductDetails(
      fullname: fullname ?? this.fullname,
      brandname: brandname != null ? brandname() : this.brandname,
      variant: variant != null ? variant() : this.variant,
      categoryGuess:
          categoryGuess != null ? categoryGuess() : this.categoryGuess,
      packagingSize:
          packagingSize != null ? packagingSize() : this.packagingSize,
    );
  }

  factory ProductDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProductDetails(fullname: 'Unknown Product');
    return ProductDetails(
      fullname: json['fullname'] ?? 'Unknown Product',
      brandname: json['brandname'],
      variant: json['variant'],
      categoryGuess: json['category_guess'],
      packagingSize:
          json['packaging_size'] != null
              ? Quantity.fromJson(json['packaging_size'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'brandname': brandname,
    'variant': variant,
    'category_guess': categoryGuess,
    'packaging_size': packagingSize?.toJson(),
  };
}

@immutable
class ServingSize {
  final num? value;
  final String? unit;
  final String? textDescription;

  const ServingSize({this.value, this.unit, this.textDescription});

  // ... fromJson, toJson ...

  ServingSize copyWith({
    ValueGetter<num?>? value,
    ValueGetter<String?>? unit,
    ValueGetter<String?>? textDescription,
  }) {
    return ServingSize(
      value: value != null ? value() : this.value,
      unit: unit != null ? unit() : this.unit,
      textDescription:
          textDescription != null ? textDescription() : this.textDescription,
    );
  }

  factory ServingSize.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServingSize();
    return ServingSize(
      value: json['value'],
      unit: json['unit'],
      textDescription: json['text_description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'unit': unit,
    'text_description': textDescription,
  };
}

@immutable
class NutritionLabel {
  final ServingSize? servingSize;
  final num? servingsPerContainer;
  // Use List<NutrientDetail> as per V1 prompt structure
  final List<NutrientDetail> macroNutrients;
  final List<NutrientDetail> microNutrients;
  final List<String>? possibleAllergens;
  final List<String>? dietaryFlags;
  final List<String>? ingredientsList;
  final String? countryOfOrigin;
  final String? labelFormat;

  const NutritionLabel({
    this.servingSize,
    this.servingsPerContainer,
    this.macroNutrients = const [], // Updated type and default
    this.microNutrients = const [], // Updated type and default
    this.possibleAllergens,
    this.dietaryFlags,
    this.ingredientsList,
    this.countryOfOrigin,
    this.labelFormat,
  });

  factory NutritionLabel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NutritionLabel();

    // Helper to parse list of dynamics into List<NutrientDetail>
    List<NutrientDetail> parseNutrientList(List<dynamic>? list) {
      return list
              ?.map(
                (n) => NutrientDetail.fromJson(n as Map<String, dynamic>?),
              ) // Ensure cast
              .where((n) => n != null)
              .cast<NutrientDetail>() // Filter nulls
              .toList() ??
          [];
    }

    return NutritionLabel(
      servingSize:
          json['serving_size'] != null
              ? ServingSize.fromJson(
                json['serving_size'] as Map<String, dynamic>?,
              ) // Ensure cast
              : null,
      servingsPerContainer: json['servings_per_container'],
      // Parse lists using helper
      macroNutrients: parseNutrientList(
        json['macro_nutrients'] as List<dynamic>?,
      ),
      microNutrients: parseNutrientList(
        json['micro_nutrients'] as List<dynamic>?,
      ),
      possibleAllergens:
          (json['possible_allergens'] as List<dynamic>?)?.cast<String>(),
      dietaryFlags: (json['dietary_flags'] as List<dynamic>?)?.cast<String>(),
      ingredientsList:
          (json['ingredients_list'] as List<dynamic>?)?.cast<String>(),
      countryOfOrigin: json['country_of_origin'],
      labelFormat: json['label_format'],
    );
  }

  Map<String, dynamic> toJson() => {
    'serving_size': servingSize?.toJson(),
    'servings_per_container': servingsPerContainer,
    // Serialize lists
    'macro_nutrients': macroNutrients.map((n) => n.toJson()).toList(),
    'micro_nutrients': microNutrients.map((n) => n.toJson()).toList(),
    'possible_allergens': possibleAllergens,
    'dietary_flags': dietaryFlags,
    'ingredients_list': ingredientsList,
    'country_of_origin': countryOfOrigin,
    'label_format': labelFormat,
  };

  NutritionLabel copyWith({
    ValueGetter<ServingSize?>? servingSize,
    ValueGetter<num?>? servingsPerContainer,
    List<NutrientDetail>? macroNutrients, // Updated type
    List<NutrientDetail>? microNutrients, // Updated type
    ValueGetter<List<String>?>? possibleAllergens,
    ValueGetter<List<String>?>? dietaryFlags,
    ValueGetter<List<String>?>? ingredientsList,
    ValueGetter<String?>? countryOfOrigin,
    ValueGetter<String?>? labelFormat,
  }) {
    return NutritionLabel(
      servingSize: servingSize != null ? servingSize() : this.servingSize,
      servingsPerContainer:
          servingsPerContainer != null
              ? servingsPerContainer()
              : this.servingsPerContainer,
      macroNutrients: macroNutrients ?? this.macroNutrients,
      microNutrients: microNutrients ?? this.microNutrients,
      possibleAllergens:
          possibleAllergens != null
              ? possibleAllergens()
              : this.possibleAllergens,
      dietaryFlags: dietaryFlags != null ? dietaryFlags() : this.dietaryFlags,
      ingredientsList:
          ingredientsList != null ? ingredientsList() : this.ingredientsList,
      countryOfOrigin:
          countryOfOrigin != null ? countryOfOrigin() : this.countryOfOrigin,
      labelFormat: labelFormat != null ? labelFormat() : this.labelFormat,
    );
  }
}

@immutable
class ProductAnalysisModel {
  final String status;
  final String? errorMessage;
  final ImageQuality imageQuality;
  final double? analysisConfidence;
  final ProductDetails productDetails;
  final NutritionLabel nutritionLabel;
  final HealthAssessment? healthAssessment;
  final bool isVerified;
  final String? frontImageUrl; // <-- Added field for image reference

  const ProductAnalysisModel({
    required this.status,
    this.errorMessage,
    required this.imageQuality,
    this.analysisConfidence,
    required this.productDetails,
    required this.nutritionLabel,
    this.healthAssessment,
    this.isVerified = false,
    this.frontImageUrl, // <-- Added to constructor
  });

  factory ProductAnalysisModel.fromJson(Map<String, dynamic> json) {
    // Note: frontImageUrl is typically NOT in the AI JSON response.
    return ProductAnalysisModel(
      status: json['status'] ?? 'Failure',
      errorMessage: json['error_message'],
      imageQuality: ImageQuality.fromJson(
        json['image_quality'] as Map<String, dynamic>?,
      ),
      analysisConfidence: (json['analysis_confidence'] as num?)?.toDouble(),
      productDetails: ProductDetails.fromJson(
        json['product_details'] as Map<String, dynamic>?,
      ),
      nutritionLabel: NutritionLabel.fromJson(
        json['nutrition_label'] as Map<String, dynamic>?,
      ),
      healthAssessment:
          json['health_assessment'] != null
              ? HealthAssessment.fromJson(
                json['health_assessment'] as Map<String, dynamic>?,
              )
              : null,
      isVerified: json['isVerified'] ?? false,
      frontImageUrl: json['frontImageUrl'], // <-- Parse if available
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'error_message': errorMessage,
    'image_quality': imageQuality.toJson(),
    'analysis_confidence': analysisConfidence,
    'product_details': productDetails.toJson(),
    'nutrition_label': nutritionLabel.toJson(),
    'health_assessment': healthAssessment?.toJson(),
    'isVerified': isVerified,
    'frontImageUrl': frontImageUrl, // <-- Serialize image reference
  };

  ProductAnalysisModel copyWith({
    String? status,
    ValueGetter<String?>? errorMessage,
    ImageQuality? imageQuality,
    ValueGetter<double?>? analysisConfidence,
    ProductDetails? productDetails,
    NutritionLabel? nutritionLabel,
    ValueGetter<HealthAssessment?>? healthAssessment,
    bool? isVerified,
    ValueGetter<String?>? frontImageUrl, // <-- Added to copyWith
  }) {
    return ProductAnalysisModel(
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      imageQuality: imageQuality ?? this.imageQuality,
      analysisConfidence:
          analysisConfidence != null
              ? analysisConfidence()
              : this.analysisConfidence,
      productDetails: productDetails ?? this.productDetails,
      nutritionLabel: nutritionLabel ?? this.nutritionLabel,
      healthAssessment:
          healthAssessment != null ? healthAssessment() : this.healthAssessment,
      isVerified: isVerified ?? this.isVerified,
      frontImageUrl:
          frontImageUrl != null
              ? frontImageUrl()
              : this.frontImageUrl, // <-- Handle copy
    );
  }
}
