class UserPreferences {
  final bool darkMode;
  final String language;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> privacySettings;
  final List<String> dietaryRestrictions;
  final List<String> allergies;

  UserPreferences({
    required this.darkMode,
    required this.language,
    required this.notificationSettings,
    required this.privacySettings,
    required this.dietaryRestrictions,
    required this.allergies,
  });

  static UserPreferences empty() => UserPreferences(
    darkMode: false,
    language: 'en',
    notificationSettings: {},
    privacySettings: {},
    dietaryRestrictions: [],
    allergies: [],
  );

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'language': language,
    'notificationSettings': notificationSettings,
    'privacySettings': privacySettings,
    'dietaryRestrictions': dietaryRestrictions,
    'allergies': allergies,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'en',
      notificationSettings: json['notificationSettings'] ?? {},
      privacySettings: json['privacySettings'] ?? {},
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }
}
