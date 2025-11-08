import 'package:cloud_firestore/cloud_firestore.dart';

class UserPublicModel {
  final String id;

  String username;
  String fullName;
  int likes;
  String bio;
  String bgImg;
  String profileUrl;
  String gender;

  UserPublicModel({
    required this.likes,
    required this.bio,
    required this.id,
    required this.username,
    required this.fullName,
    required this.bgImg,
    required this.profileUrl,
    required this.gender,
  });

  // String get formattedPhoneNumber => SFormatter.formatPhoneNumber(phoneNumber);

  static List<String> nameParts(name) {
    return name.split(' ');
  }

  static UserPublicModel empty() => UserPublicModel(
        id: '',
        username: '',
        fullName: '',
        bgImg: '',
        profileUrl: '',
        bio: '',
        gender: '',
        likes: 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'bgImg': bgImg,
      'profileUrl': profileUrl,
      'bio': bio,
      'likes': likes,
      'gender': gender,
    };
  }

  static UserPublicModel fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserPublicModel(
        id: document.id,
        username: data['username'] ?? '',
        fullName: data['fullName'] ?? '',
        bgImg: data['bgImg'] ?? '',
        profileUrl: data['profileUrl'] ?? '',
        bio: data['bio'] ?? '',
        likes: data['likes'] ?? 0,
        gender: data['gender'] ?? '',
      );
    } else {
      return UserPublicModel.empty();
    }
  }
}
