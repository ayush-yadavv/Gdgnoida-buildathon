/// A model class representing a user's daily food intake and nutrition data.
/// This model stores information about what foods were consumed, their nutritional values,
/// and how they were distributed across different meal types for a specific day.
class DailyIntakeModel {
  /// Unque identifier for this daily intake record
  final String id;

  /// ID of the user this intake record belongs to
  final String userId;

  /// The date this intake record is for
  final DateTime date;

  /// Map of nutrient names to their total amounts consumed for the day
  /// e.g. {'protein': 65.5, 'carbs': 200.0, 'fat': 55.0}
  final Map<String, double> totalNutrients;

  /// List of IDs referencing the specific food items consumed
  final List<String> foodIds;

  /// Breakdown of calories/nutrients by meal type
  /// e.g. {'breakfast': 500.0, 'lunch': 600.0, 'dinner': 700.0}
  final Map<String, double> mealTypeBreakdown;

  /// Timestamp when this record was first created
  final DateTime createdAt;

  /// Timestamp when this record was last modified
  final DateTime updatedAt;

  /// Creates a new DailyIntakeModel with the required fields
  DailyIntakeModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalNutrients,
    required this.foodIds,
    required this.mealTypeBreakdown,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this model instance to a JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'date': date.toIso8601String(),
    'totalNutrients': totalNutrients,
    'foodIds': foodIds,
    'mealTypeBreakdown': mealTypeBreakdown,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Creates a DailyIntakeModel instance from a JSON map
  factory DailyIntakeModel.fromJson(Map<String, dynamic> json) {
    return DailyIntakeModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      totalNutrients: Map<String, double>.from(json['totalNutrients'] ?? {}),
      foodIds: List<String>.from(json['foodIds'] ?? []),
      mealTypeBreakdown: Map<String, double>.from(
        json['mealTypeBreakdown'] ?? {},
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Creates a copy of this DailyIntakeModel with optionally updated fields
  DailyIntakeModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Map<String, double>? totalNutrients,
    List<String>? foodIds,
    Map<String, double>? mealTypeBreakdown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyIntakeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalNutrients: totalNutrients ?? this.totalNutrients,
      foodIds: foodIds ?? this.foodIds,
      mealTypeBreakdown: mealTypeBreakdown ?? this.mealTypeBreakdown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates an empty DailyIntakeModel with default values
  /// Useful for initializing new records or placeholder data
  factory DailyIntakeModel.empty() {
    return DailyIntakeModel(
      id: '',
      userId: '',
      date: DateTime.now(),
      totalNutrients: {},
      foodIds: [],
      mealTypeBreakdown: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
