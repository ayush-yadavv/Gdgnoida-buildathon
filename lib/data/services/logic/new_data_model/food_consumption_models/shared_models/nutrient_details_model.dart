// import 'package:flutter/foundation.dart';

// class NutrientDetail {
//   final String name;
//   final num? value;
//   final String? unit;
//   final String? healthImpact; // Good | Bad | Moderate

//   const NutrientDetail({
//     required this.name,
//     this.value,
//     this.unit,
//     this.healthImpact,
//   });

//   // ... fromJson, toJson ...

//   NutrientDetail copyWith({
//     String? name,
//     ValueGetter<num?>? value,
//     ValueGetter<String?>? unit,
//     ValueGetter<String?>? healthImpact,
//   }) {
//     return NutrientDetail(
//       name: name ?? this.name,
//       value: value != null ? value() : this.value,
//       unit: unit != null ? unit() : this.unit,
//       healthImpact: healthImpact != null ? healthImpact() : this.healthImpact,
//     );
//   }

//   factory NutrientDetail.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       // Return a default or handle appropriately
//       return const NutrientDetail(name: 'Unknown');
//     }
//     return NutrientDetail(
//       name: json['name'] ?? 'Unknown',
//       value: json['value'], // Allow null
//       unit: json['unit'], // Allow null
//       healthImpact: json['health_impact'], // Allow null
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'value': value,
//     'unit': unit,
//     'health_impact': healthImpact,
//   };
// }
