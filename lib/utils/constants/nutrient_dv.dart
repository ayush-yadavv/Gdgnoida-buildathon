import 'package:eat_right/temp/dv_values.dart';

/// Manages Daily Values (DV) for nutrients based on the latest guidelines
class NutrientDV {
  // Cache for parsed DV values
  static final Map<String, double> _dvCache = {};
  static bool _isInitialized = false;

  /// Initialize the DV cache from the nutrient data
  static void _initialize() {
    if (_isInitialized) return;

    for (var nutrient in nutrientData) {
      final name = nutrient['Nutrient'] as String;
      final valueStr = (nutrient['Current Daily Value'] as String)
          .replaceAll('mcg DFE', '') // Handle special cases
          .replaceAll('mg NE', '')
          .replaceAll('mcg RAE', '')
          .replaceAll('mg alpha-tocopherol', '')
          .trim();

      // Extract numeric value and unit
      final valueMatch = RegExp(r'([0-9.]+)').firstMatch(valueStr);
      if (valueMatch != null) {
        final value = double.tryParse(valueMatch.group(1)!) ?? 0;
        _dvCache[name.toLowerCase()] = value;
      }
    }
    _isInitialized = true;
  }

  /// Returns the standard Daily Value for a given nutrient name
  /// Returns null if no standard DV is defined for the nutrient
  static double? getDailyValue(String nutrientName) {
    _initialize();
    
    // Try direct match first
    final name = nutrientName.toLowerCase();
    if (_dvCache.containsKey(name)) {
      return _dvCache[name];
    }

    // Try partial matches for common variations
    for (var key in _dvCache.keys) {
      if (name.contains(key) || key.contains(name)) {
        return _dvCache[key];
      }
    }

    // Handle special cases and aliases
    final normalizedName = name
        .replaceAll('total ', '')
        .replaceAll('dietary ', '')
        .replaceAll('folic acid', 'folate')
        .replaceAll('b1', 'thiamin')
        .replaceAll('b2', 'riboflavin')
        .replaceAll('b3', 'niacin')
        .replaceAll('b5', 'pantothenic acid')
        .replaceAll('b6', 'vitamin b6')
        .replaceAll('b7', 'biotin')
        .replaceAll('b9', 'folate')
        .replaceAll('b12', 'vitamin b12')
        .trim();

    return _dvCache[normalizedName];
  }

  /// Calculates the percentage of Daily Value for a given nutrient amount
  /// Returns null if the DV for the nutrient is not defined
  static int? calculateDailyValuePercentage(String nutrientName, double amount) {
    final dv = getDailyValue(nutrientName);
    if (dv == null || dv == 0) return null;
    return ((amount / dv) * 100).round();
  }

  /// Returns the goal type for a nutrient (e.g., 'At least', 'Less than')
  static String? getNutrientGoal(String nutrientName) {
    _initialize();
    final name = nutrientName.toLowerCase();
    
    // Find the nutrient data that matches the name
    for (var nutrient in nutrientData) {
      if (nutrient['Nutrient'].toString().toLowerCase() == name) {
        return nutrient['Goal'] as String?;
      }
    }
    return null;
  }
}
