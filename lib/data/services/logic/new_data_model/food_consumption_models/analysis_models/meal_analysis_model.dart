// lib/data/models/meal_analysis_model.dart

import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/health_assesment_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/nutrient_info_model.dart';
import 'package:flutter/foundation.dart';

// --- MealDetails, EstimationDetails remain the same ---
// ... (Keep existing MealDetails and EstimationDetails classes) ...
@immutable
class MealDetails {
  final String? nameSuggestion;
  final String? mealType;
  final String? cuisineStyle;
  final Quantity? estimatedTotalWeight;

  const MealDetails({
    this.nameSuggestion,
    this.mealType,
    this.cuisineStyle,
    this.estimatedTotalWeight,
  });

  // ... fromJson, toJson ...

  MealDetails copyWith({
    ValueGetter<String?>? nameSuggestion,
    ValueGetter<String?>? mealType,
    ValueGetter<String?>? cuisineStyle,
    ValueGetter<Quantity?>? estimatedTotalWeight,
  }) {
    return MealDetails(
      nameSuggestion:
          nameSuggestion != null ? nameSuggestion() : this.nameSuggestion,
      mealType: mealType != null ? mealType() : this.mealType,
      cuisineStyle: cuisineStyle != null ? cuisineStyle() : this.cuisineStyle,
      estimatedTotalWeight:
          estimatedTotalWeight != null
              ? estimatedTotalWeight()
              : this.estimatedTotalWeight,
    );
  }

  factory MealDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MealDetails();
    return MealDetails(
      nameSuggestion: json['name_suggestion'],
      mealType: json['meal_type'],
      cuisineStyle: json['cuisine_style'],
      estimatedTotalWeight:
          json['estimated_total_weight'] != null
              ? Quantity.fromJson(json['estimated_total_weight'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name_suggestion': nameSuggestion,
    'meal_type': mealType,
    'cuisine_style': cuisineStyle,
    'estimated_total_weight': estimatedTotalWeight?.toJson(),
  };
}

@immutable
class EstimationDetails {
  final List<String>? visualCues;
  final String? reasoning;
  final double? confidence; // Use double for 0.0-1.0

  const EstimationDetails({this.visualCues, this.reasoning, this.confidence});

  // ... fromJson, toJson ...

  EstimationDetails copyWith({
    ValueGetter<List<String>?>? visualCues,
    ValueGetter<String?>? reasoning,
    ValueGetter<double?>? confidence,
  }) {
    return EstimationDetails(
      visualCues: visualCues != null ? visualCues() : this.visualCues,
      reasoning: reasoning != null ? reasoning() : this.reasoning,
      confidence: confidence != null ? confidence() : this.confidence,
    );
  }

  factory EstimationDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EstimationDetails();
    return EstimationDetails(
      visualCues: (json['visual_cues'] as List<dynamic>?)?.cast<String>(),
      reasoning: json['reasoning'],
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'visual_cues': visualCues,
    'reasoning': reasoning,
    'confidence': confidence,
  };
}

@immutable
class MealItem {
  final String itemName;
  final String? itemCategory;
  final String? preparationMethod;
  final Quantity estimatedQuantity;
  // Use the refactored NutrientInfo
  final NutrientInfo nutrientsForEstimatedQuantity;
  final NutrientInfo nutrientsPer100g;
  final List<String>? possibleAllergens;
  final List<String>? dietaryFlags;
  final EstimationDetails? estimationDetails;

  const MealItem({
    required this.itemName,
    this.itemCategory,
    this.preparationMethod,
    required this.estimatedQuantity,
    required this.nutrientsForEstimatedQuantity, // Updated type
    required this.nutrientsPer100g, // Updated type
    this.possibleAllergens,
    this.dietaryFlags,
    this.estimationDetails,
  });

  factory MealItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError("Cannot create MealItem from null json");
    }
    return MealItem(
      itemName: json['item_name'] ?? 'Unknown Item',
      itemCategory: json['item_category'],
      preparationMethod: json['preparation_method'],
      estimatedQuantity: Quantity.fromJson(json['estimated_quantity']),
      // Use NutrientInfo.fromJson
      nutrientsForEstimatedQuantity: NutrientInfo.fromJson(
        json['nutrients_for_estimated_quantity'] as Map<String, dynamic>?,
      ),
      nutrientsPer100g: NutrientInfo.fromJson(
        json['nutrients_per_100g'] as Map<String, dynamic>?,
      ),
      possibleAllergens:
          (json['possible_allergens'] as List<dynamic>?)?.cast<String>(),
      dietaryFlags: (json['dietary_flags'] as List<dynamic>?)?.cast<String>(),
      estimationDetails:
          json['estimation_details'] != null
              ? EstimationDetails.fromJson(json['estimation_details'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'item_category': itemCategory,
    'preparation_method': preparationMethod,
    'estimated_quantity': estimatedQuantity.toJson(),
    // Use NutrientInfo.toJson
    'nutrients_for_estimated_quantity': nutrientsForEstimatedQuantity.toJson(),
    'nutrients_per_100g': nutrientsPer100g.toJson(),
    'possible_allergens': possibleAllergens,
    'dietary_flags': dietaryFlags,
    'estimation_details': estimationDetails?.toJson(),
  };

  MealItem copyWith({
    String? itemName,
    ValueGetter<String?>? itemCategory,
    ValueGetter<String?>? preparationMethod,
    Quantity? estimatedQuantity,
    NutrientInfo? nutrientsForEstimatedQuantity, // Updated type
    NutrientInfo? nutrientsPer100g, // Updated type
    ValueGetter<List<String>?>? possibleAllergens,
    ValueGetter<List<String>?>? dietaryFlags,
    ValueGetter<EstimationDetails?>? estimationDetails,
  }) {
    return MealItem(
      itemName: itemName ?? this.itemName,
      itemCategory: itemCategory != null ? itemCategory() : this.itemCategory,
      preparationMethod:
          preparationMethod != null
              ? preparationMethod()
              : this.preparationMethod,
      estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
      nutrientsForEstimatedQuantity:
          nutrientsForEstimatedQuantity ?? this.nutrientsForEstimatedQuantity,
      nutrientsPer100g: nutrientsPer100g ?? this.nutrientsPer100g,
      possibleAllergens:
          possibleAllergens != null
              ? possibleAllergens()
              : this.possibleAllergens,
      dietaryFlags: dietaryFlags != null ? dietaryFlags() : this.dietaryFlags,
      estimationDetails:
          estimationDetails != null
              ? estimationDetails()
              : this.estimationDetails,
    );
  }
}

@immutable
class MealAnalysisModel {
  final String status;
  final String? errorMessage;
  final double? analysisConfidence;
  final String? foodImageQuality;
  final MealDetails mealDetails;
  final List<MealItem> items;
  final NutrientInfo totalMealNutrients;
  final HealthAssessment? healthAssessment;
  final bool isVerified;
  final String? frontImageUrl; // <-- Added field for image reference

  const MealAnalysisModel({
    required this.status,
    this.errorMessage,
    this.analysisConfidence,
    this.foodImageQuality,
    required this.mealDetails,
    required this.items,
    required this.totalMealNutrients,
    this.healthAssessment,
    this.isVerified = false,
    this.frontImageUrl, // <-- Added to constructor
  });

  factory MealAnalysisModel.fromJson(Map<String, dynamic> json) {
    // Note: frontImageUrl is typically NOT in the AI JSON response.
    // It's usually set *after* parsing and uploading the source image.
    return MealAnalysisModel(
      status: json['status'] ?? 'Failure',
      errorMessage: json['error_message'],
      analysisConfidence: (json['analysis_confidence'] as num?)?.toDouble(),
      foodImageQuality: json['food_image_quality'],
      mealDetails: MealDetails.fromJson(
        json['meal_details'] as Map<String, dynamic>?,
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>?))
              .where((item) => item != null)
              .cast<MealItem>()
              .toList() ??
          [],
      totalMealNutrients: NutrientInfo.fromJson(
        json['total_meal_nutrients'] as Map<String, dynamic>?,
      ),
      healthAssessment:
          json['health_assessment'] != null
              ? HealthAssessment.fromJson(
                json['health_assessment'] as Map<String, dynamic>?,
              )
              : null,
      isVerified: json['isVerified'] ?? false,
      frontImageUrl:
          json['frontImageUrl'], // <-- Parse if available (unlikely from AI)
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'error_message': errorMessage,
    'analysis_confidence': analysisConfidence,
    'food_image_quality': foodImageQuality,
    'meal_details': mealDetails.toJson(),
    'items': items.map((item) => item.toJson()).toList(),
    'total_meal_nutrients': totalMealNutrients.toJson(),
    'health_assessment': healthAssessment?.toJson(),
    'isVerified': isVerified,
    'frontImageUrl': frontImageUrl, // <-- Serialize image reference
  };

  MealAnalysisModel copyWith({
    String? status,
    ValueGetter<String?>? errorMessage,
    ValueGetter<double?>? analysisConfidence,
    ValueGetter<String?>? foodImageQuality,
    MealDetails? mealDetails,
    List<MealItem>? items,
    NutrientInfo? totalMealNutrients,
    ValueGetter<HealthAssessment?>? healthAssessment,
    bool? isVerified,
    ValueGetter<String?>? frontImageUrl, // <-- Added to copyWith
  }) {
    return MealAnalysisModel(
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      analysisConfidence:
          analysisConfidence != null
              ? analysisConfidence()
              : this.analysisConfidence,
      foodImageQuality:
          foodImageQuality != null ? foodImageQuality() : this.foodImageQuality,
      mealDetails: mealDetails ?? this.mealDetails,
      items: items ?? this.items,
      totalMealNutrients: totalMealNutrients ?? this.totalMealNutrients,
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
// // lib/data/models/meal_analysis_model.dart

// import 'package:eat_right/data/services/logic/new_data_model/base_models/quantity_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/health_assesment_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/shared_models/nutrient_info_model.dart';
// import 'package:flutter/foundation.dart';

// @immutable
// class MealDetails {
//   final String? nameSuggestion;
//   final String? mealType;
//   final String? cuisineStyle;
//   final Quantity? estimatedTotalWeight;

//   const MealDetails({
//     this.nameSuggestion,
//     this.mealType,
//     this.cuisineStyle,
//     this.estimatedTotalWeight,
//   });

//   // ... fromJson, toJson ...

//   MealDetails copyWith({
//     ValueGetter<String?>? nameSuggestion,
//     ValueGetter<String?>? mealType,
//     ValueGetter<String?>? cuisineStyle,
//     ValueGetter<Quantity?>? estimatedTotalWeight,
//   }) {
//     return MealDetails(
//       nameSuggestion:
//           nameSuggestion != null ? nameSuggestion() : this.nameSuggestion,
//       mealType: mealType != null ? mealType() : this.mealType,
//       cuisineStyle: cuisineStyle != null ? cuisineStyle() : this.cuisineStyle,
//       estimatedTotalWeight:
//           estimatedTotalWeight != null
//               ? estimatedTotalWeight()
//               : this.estimatedTotalWeight,
//     );
//   }

//   factory MealDetails.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return const MealDetails();
//     return MealDetails(
//       nameSuggestion: json['name_suggestion'],
//       mealType: json['meal_type'],
//       cuisineStyle: json['cuisine_style'],
//       estimatedTotalWeight:
//           json['estimated_total_weight'] != null
//               ? Quantity.fromJson(json['estimated_total_weight'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'name_suggestion': nameSuggestion,
//     'meal_type': mealType,
//     'cuisine_style': cuisineStyle,
//     'estimated_total_weight': estimatedTotalWeight?.toJson(),
//   };
// }

// @immutable
// class EstimationDetails {
//   final List<String>? visualCues;
//   final String? reasoning;
//   final double? confidence; // Use double for 0.0-1.0

//   const EstimationDetails({this.visualCues, this.reasoning, this.confidence});

//   // ... fromJson, toJson ...

//   EstimationDetails copyWith({
//     ValueGetter<List<String>?>? visualCues,
//     ValueGetter<String?>? reasoning,
//     ValueGetter<double?>? confidence,
//   }) {
//     return EstimationDetails(
//       visualCues: visualCues != null ? visualCues() : this.visualCues,
//       reasoning: reasoning != null ? reasoning() : this.reasoning,
//       confidence: confidence != null ? confidence() : this.confidence,
//     );
//   }

//   factory EstimationDetails.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return const EstimationDetails();
//     return EstimationDetails(
//       visualCues: (json['visual_cues'] as List<dynamic>?)?.cast<String>(),
//       reasoning: json['reasoning'],
//       confidence: (json['confidence'] as num?)?.toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'visual_cues': visualCues,
//     'reasoning': reasoning,
//     'confidence': confidence,
//   };
// }

// @immutable
// class MealItem {
//   final String itemName;
//   final String? itemCategory;
//   final String? preparationMethod;
//   final Quantity estimatedQuantity;
//   final NutrientInfo nutrientsForEstimatedQuantity;
//   final NutrientInfo nutrientsPer100g;
//   final List<String>? possibleAllergens;
//   final List<String>? dietaryFlags;
//   final EstimationDetails? estimationDetails;

//   const MealItem({
//     required this.itemName,
//     this.itemCategory,
//     this.preparationMethod,
//     required this.estimatedQuantity,
//     required this.nutrientsForEstimatedQuantity,
//     required this.nutrientsPer100g,
//     this.possibleAllergens,
//     this.dietaryFlags,
//     this.estimationDetails,
//   });

//   // ... fromJson, toJson ...

//   MealItem copyWith({
//     String? itemName,
//     ValueGetter<String?>? itemCategory,
//     ValueGetter<String?>? preparationMethod,
//     Quantity? estimatedQuantity,
//     NutrientInfo? nutrientsForEstimatedQuantity,
//     NutrientInfo? nutrientsPer100g,
//     ValueGetter<List<String>?>? possibleAllergens,
//     ValueGetter<List<String>?>? dietaryFlags,
//     ValueGetter<EstimationDetails?>? estimationDetails,
//   }) {
//     return MealItem(
//       itemName: itemName ?? this.itemName,
//       itemCategory: itemCategory != null ? itemCategory() : this.itemCategory,
//       preparationMethod:
//           preparationMethod != null
//               ? preparationMethod()
//               : this.preparationMethod,
//       estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
//       nutrientsForEstimatedQuantity:
//           nutrientsForEstimatedQuantity ?? this.nutrientsForEstimatedQuantity,
//       nutrientsPer100g: nutrientsPer100g ?? this.nutrientsPer100g,
//       possibleAllergens:
//           possibleAllergens != null
//               ? possibleAllergens()
//               : this.possibleAllergens,
//       dietaryFlags: dietaryFlags != null ? dietaryFlags() : this.dietaryFlags,
//       estimationDetails:
//           estimationDetails != null
//               ? estimationDetails()
//               : this.estimationDetails,
//     );
//   }

//   factory MealItem.fromJson(Map<String, dynamic>? json) {
//     if (json == null)
//       throw ArgumentError("Cannot create MealItem from null json");
//     return MealItem(
//       itemName: json['item_name'] ?? 'Unknown Item',
//       itemCategory: json['item_category'],
//       preparationMethod: json['preparation_method'],
//       estimatedQuantity: Quantity.fromJson(json['estimated_quantity']),
//       nutrientsForEstimatedQuantity: NutrientInfo.fromJson(
//         json['nutrients_for_estimated_quantity'],
//       ),
//       nutrientsPer100g: NutrientInfo.fromJson(json['nutrients_per_100g']),
//       possibleAllergens:
//           (json['possible_allergens'] as List<dynamic>?)?.cast<String>(),
//       dietaryFlags: (json['dietary_flags'] as List<dynamic>?)?.cast<String>(),
//       estimationDetails:
//           json['estimation_details'] != null
//               ? EstimationDetails.fromJson(json['estimation_details'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'item_name': itemName,
//     'item_category': itemCategory,
//     'preparation_method': preparationMethod,
//     'estimated_quantity': estimatedQuantity.toJson(),
//     'nutrients_for_estimated_quantity': nutrientsForEstimatedQuantity.toJson(),
//     'nutrients_per_100g': nutrientsPer100g.toJson(),
//     'possible_allergens': possibleAllergens,
//     'dietary_flags': dietaryFlags,
//     'estimation_details': estimationDetails?.toJson(),
//   };
// }

// @immutable
// class MealAnalysisModel {
//   final String status;
//   final String? errorMessage;
//   final double? analysisConfidence;
//   final MealDetails mealDetails;
//   final List<MealItem> items;
//   final NutrientInfo totalMealNutrients;
//   final HealthAssessment? healthAssessment; // Make nullable as per prompt
//   final bool isVerified; // Added isVerified field

//   const MealAnalysisModel({
//     required this.status,
//     this.errorMessage,
//     this.analysisConfidence,
//     required this.mealDetails,
//     required this.items,
//     required this.totalMealNutrients,
//     this.healthAssessment,
//     this.isVerified = false, // Default to false
//   });

//   factory MealAnalysisModel.fromJson(Map<String, dynamic> json) {
//     // Assuming 'json' is the content of "meal_analysis" key:
//     return MealAnalysisModel(
//       status: json['status'] ?? 'Failure',
//       errorMessage: json['error_message'],
//       analysisConfidence: (json['analysis_confidence'] as num?)?.toDouble(),
//       mealDetails: MealDetails.fromJson(json['meal_details']),
//       items:
//           (json['items'] as List<dynamic>?)
//               ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//       totalMealNutrients: NutrientInfo.fromJson(json['total_meal_nutrients']),
//       healthAssessment:
//           json['health_assessment'] != null
//               ? HealthAssessment.fromJson(json['health_assessment'])
//               : null,
//       isVerified: json['isVerified'] ?? false, // Parse isVerified
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'status': status,
//     'error_message': errorMessage,
//     'analysis_confidence': analysisConfidence,
//     'meal_details': mealDetails.toJson(),
//     'items': items.map((item) => item.toJson()).toList(),
//     'total_meal_nutrients': totalMealNutrients.toJson(),
//     'health_assessment': healthAssessment?.toJson(),
//     'isVerified': isVerified, // Serialize isVerified
//   };

//   // Added copyWith method
//   MealAnalysisModel copyWith({
//     String? status,
//     ValueGetter<String?>? errorMessage,
//     ValueGetter<double?>? analysisConfidence,
//     MealDetails? mealDetails,
//     List<MealItem>? items,
//     NutrientInfo? totalMealNutrients,
//     ValueGetter<HealthAssessment?>? healthAssessment,
//     bool? isVerified,
//   }) {
//     return MealAnalysisModel(
//       status: status ?? this.status,
//       errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
//       analysisConfidence:
//           analysisConfidence != null
//               ? analysisConfidence()
//               : this.analysisConfidence,
//       mealDetails: mealDetails ?? this.mealDetails,
//       items: items ?? this.items,
//       totalMealNutrients: totalMealNutrients ?? this.totalMealNutrients,
//       healthAssessment:
//           healthAssessment != null ? healthAssessment() : this.healthAssessment,
//       isVerified: isVerified ?? this.isVerified,
//     );
//   }
// }
