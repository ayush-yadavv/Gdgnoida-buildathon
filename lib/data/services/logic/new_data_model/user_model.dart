// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eat_right/utils/formatters/formatter.dart';

// class UserModel {
//   final String id;
//   String email;
//   String username;
//   String fullName;
//   int likes;
//   String bio;
//   String bgImg;
//   String profileUrl;
//   String gender;
//   String phoneNo;
//   String dob;

//   UserModel({
//     required this.likes,
//     required this.bio,
//     required this.id,
//     required this.email,
//     required this.username,
//     required this.fullName,
//     required this.bgImg,
//     required this.profileUrl,
//     required this.gender,
//     required this.phoneNo,
//     required this.dob,
//   });

//   String get formattedPhoneNumber => SFormatter.formatPhoneNumber(phoneNo);

//   static List<String> nameParts(name) {
//     return name.split(' ');
//   }

//   static UserModel empty() => UserModel(
//     id: '',
//     email: '',
//     username: '',
//     fullName: '',
//     bgImg: '',
//     profileUrl: '',
//     bio: '',
//     gender: '',
//     likes: 0,
//     phoneNo: '-',
//     dob: '',
//   );

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'email': email,
//       'username': username,
//       'fullName': fullName,
//       'bgImg': bgImg,
//       'profileUrl': profileUrl,
//       'bio': bio,
//       'likes': likes,
//       'gender': gender,
//       'phoneNo': phoneNo,
//       'dob': dob,
//     };
//   }

//   static UserModel fromSnapshot(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) {
//     if (document.data() != null) {
//       final data = document.data()!;
//       return UserModel(
//         id: document.id,
//         email: data['email'] ?? '',
//         username: data['username'] ?? '',
//         fullName: data['fullName'] ?? '',
//         bgImg: data['bgImg'] ?? '',
//         profileUrl: data['profileUrl'] ?? '',
//         bio: data['bio'] ?? '',
//         likes: data['likes'] ?? 0,
//         gender: data['gender'] ?? '',
//         phoneNo: data['phoneNo'] ?? '-',
//         dob: data['dob'] ?? '',
//       );
//     } else {
//       return UserModel.empty();
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/base_models/base_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_health_profile_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_prefrences_model.dart';
import 'package:eat_right/utils/formatters/formatter.dart';

class UserModel extends BaseModel {
  final String email;
  String username;
  String fullName;
  String profileUrl;
  String? bio;
  String? phoneNo;
  String? gender;
  DateTime? dateOfBirth;
  UserPreferences preferences;
  UserHealthProfile healthProfile;

  UserModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.email,
    required this.username,
    required this.fullName,
    required this.profileUrl,
    this.bio,
    this.phoneNo,
    this.gender,
    this.dateOfBirth,
    required this.preferences,
    required this.healthProfile,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'fullName': fullName,
    'profileUrl': profileUrl,
    'bio': bio,
    'phoneNo': phoneNo,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'preferences': preferences.toJson(),
    'healthProfile': healthProfile.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  String get formattedPhoneNumber => SFormatter.formatPhoneNumber(phoneNo!);

  static List<String> nameParts(name) {
    return name.split(' ');
  }

  static UserModel fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() != null) {
      final data = document.data()!;
      DateTime parseTimestamp(dynamic timestampData) {
        if (timestampData is Timestamp) {
          return timestampData.toDate();
        } else if (timestampData is String) {
          return DateTime.tryParse(timestampData) ?? DateTime.now();
        }
        // Default if null or unexpected type
        return DateTime.now();
      }

      return UserModel(
        id: document.id,
        email: data['email'] ?? '',
        username: data['username'] ?? '',
        fullName: data['fullName'] ?? '',
        profileUrl: data['profileUrl'] ?? '',
        bio: data['bio'] ?? '',
        gender: data['gender'] ?? '',
        phoneNo: data['phoneNo'] ?? '-',
        createdAt: parseTimestamp(data['createdAt']), // Use helper
        updatedAt: parseTimestamp(data['updatedAt']), // Use helper

        preferences:
            data['preferences'] != null
                ? UserPreferences.fromJson(data['preferences'])
                : UserPreferences.empty(),
        healthProfile:
            data['healthProfile'] != null
                ? UserHealthProfile.fromJson(data['healthProfile'])
                : UserHealthProfile.empty(),
      );
    } else {
      return UserModel.empty();
    }
  }

  static UserModel empty() => UserModel(
    id: '',
    email: '',
    username: '',
    fullName: '',
    profileUrl: '',
    bio: null,
    phoneNo: null,
    gender: null,
    dateOfBirth: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    preferences: UserPreferences.empty(),
    healthProfile: UserHealthProfile.empty(),
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      bio: json['bio'],
      phoneNo: json['phoneNo'],
      gender: json['gender'],
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      preferences:
          json['preferences'] != null
              ? UserPreferences.fromJson(json['preferences'])
              : UserPreferences.empty(),
      healthProfile:
          json['healthProfile'] != null
              ? UserHealthProfile.fromJson(json['healthProfile'])
              : UserHealthProfile.empty(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? profileUrl,
    String? bio,
    String? phoneNo,
    String? gender,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    UserHealthProfile? healthProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileUrl: profileUrl ?? this.profileUrl,
      bio: bio ?? this.bio,
      phoneNo: phoneNo ?? this.phoneNo,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      healthProfile: healthProfile ?? this.healthProfile,
    );
  }

  UserModel copyWithFromMap(Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: email,
      username: data['username'] ?? username,
      fullName: data['fullName'] ?? fullName,
      profileUrl: data['profileUrl'] ?? profileUrl,
      bio: data['bio'] ?? bio,
      phoneNo: data['phoneNo'] ?? phoneNo,
      gender: data['gender'] ?? gender,
      dateOfBirth:
          data['dateOfBirth'] != null
              ? DateTime.parse(data['dateOfBirth'])
              : dateOfBirth,
      createdAt: createdAt,
      updatedAt: DateTime.parse(data['updatedAt'] ?? updatedAt),
      preferences:
          data['preferences'] != null
              ? UserPreferences.fromJson(data['preferences'])
              : preferences,
      healthProfile:
          data['healthProfile'] != null
              ? UserHealthProfile.fromJson(data['healthProfile'])
              : healthProfile,
    );
  }
}
