class UserHealthProfile {
  final double? height;
  final double? weight;
  final double? bmi;
  final double? bmr;
  final DateTime? dateOfBirth;
  final String? activityLevel;
  final List<String>? healthConditions;
  final List<String>? healthGoals;
  final List<String>? dietaryGoals;
  final List<String>? dietaryRestrictions;
  final Map<String, dynamic>? nutrientTarget;

  UserHealthProfile({
    this.bmr,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.activityLevel,
    this.healthConditions,
    this.healthGoals,
    this.dietaryGoals,
    this.dietaryRestrictions,
    this.nutrientTarget,
  }) : bmi = _calculateBMI(height, weight);

  static double? _calculateBMI(double? height, double? weight) {
    if (height == null || weight == null || height == 0) return null;
    return weight / ((height / 100) * (height / 100));
  }

  Map<String, dynamic> toJson() => {
    'height': height ?? 0.0,
    'weight': weight ?? 0.0,
    'bmi': bmi,
    'bmr': bmr,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'activityLevel': activityLevel,
    'healthConditions': healthConditions,
    'healthGoals': healthGoals,
    'dietaryGoals': dietaryGoals,
    'dietaryRestrictions': dietaryRestrictions,
    'nutrientTarget': nutrientTarget,
  };

  static UserHealthProfile empty() => UserHealthProfile(
    height: 0.0,
    weight: 0.0,
    bmr: 0.0,
    dateOfBirth: DateTime.now(),
    activityLevel: '',
    healthConditions: [],
    healthGoals: [],
    dietaryGoals: [],
    dietaryRestrictions: [],
    nutrientTarget: {},
  );

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    double height = (json['height'] as num).toDouble();
    double weight = (json['weight'] as num).toDouble();
    return UserHealthProfile(
      height: height,
      weight: weight,
      bmr: json['bmr'] as double,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      activityLevel: json['activityLevel'] as String,
      healthConditions: List<String>.from(json['healthConditions'] as List),
      healthGoals: List<String>.from(json['healthGoals'] as List),
      dietaryGoals: List<String>.from(json['dietaryGoals'] as List),
      dietaryRestrictions: List<String>.from(
        json['dietaryRestrictions'] as List,
      ),
      nutrientTarget: Map<String, dynamic>.from(json['nutrientTarget'] as Map),
    );
  }
}
