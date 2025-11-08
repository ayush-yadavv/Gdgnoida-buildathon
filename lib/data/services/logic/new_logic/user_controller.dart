import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/repositories/user_repository/user_repository.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_health_profile_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_prefrences_model.dart';
import 'package:eat_right/utils/loaders/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  late final UserRepository _repository;
  final Rx<UserModel> user = UserModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isImageUploading = false.obs;

  // Cache for user data
  UserModel? _userCache;

  @override
  Future<void> onInit() async {
    super.onInit();
    final prefs = await SharedPreferences.getInstance();
    _repository = UserRepository(prefs);
    loadUserData();
  }

  // Load user data
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = AuthenticationRepository.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Check cache first
      if (_userCache != null) {
        user.value = _userCache!;
        isLoading.value = false;
        return;
      }

      // Load from repository
      final userData = await _repository.getUserData(userId);
      if (userData != null) {
        user.value = userData;
        _userCache = userData;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save user data
  Future<void> saveUserData(UserModel userData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _repository.saveUserData(userData);
      user.value = userData;
      _userCache = userData;

      SLoader.successSnackBar(
        title: 'Success',
        message: 'User data updated successfully',
      );
    } catch (e) {
      errorMessage.value = 'Failed to save user data: $e';
      print('Error saving user data: $e');

      SLoader.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user data',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile picture
  Future<void> updateProfilePicture() async {
    if (isImageUploading.value) return;

    try {
      isImageUploading.value = true;
      errorMessage.value = '';

      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        final userId = AuthenticationRepository.instance.currentUser?.uid;
        if (userId == null) throw Exception('User not authenticated');

        final imageUrl = await _repository.uploadProfileImage(userId, image);

        // Update local user data
        user.update((val) {
          if (val != null) {
            val.profileUrl = imageUrl;
          }
        });
        _userCache = user.value;

        SLoader.successSnackBar(
          title: 'Success',
          message: 'Profile picture updated successfully',
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to update profile picture: $e';
      print('Error updating profile picture: $e');

      SLoader.errorSnackBar(
        title: 'Error',
        message: 'Failed to update profile picture',
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  // Check username availability
  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _repository.isUsernameAvailable(username);
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Generate a unique username from email
  String _generateUsername(String email) {
    try {
      // Extract part before @ symbol
      String baseName = email.split('@')[0].toLowerCase();

      // Remove special characters and spaces
      baseName = baseName.replaceAll(RegExp(r'[^\w\s]+'), '');

      // Add random 8 digit number
      String randomNum =
          (10000000 + DateTime.now().millisecondsSinceEpoch % 90000000)
              .toString();
      return '$baseName$randomNum';
    } catch (e) {
      print('Error generating username: $e');
      // Fallback username if email parsing fails
      return 'user${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    }
  }

  // Update single user field
  Future<void> updateUserField(Map<String, dynamic> data) async {
    try {
      final userId = AuthenticationRepository.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _repository.updateUserField(userId, data);

      // Update local user data
      user.update((val) {
        if (val != null) {
          val = val.copyWithFromMap(data);
        }
      });
      _userCache = user.value;
    } catch (e) {
      errorMessage.value = 'Failed to update user field: $e';
      print('Error updating user field: $e');
      rethrow;
    }
  }

  // Handle user authentication (new or existing)
  Future<void> handleUserAuth(UserCredential? userCredential) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = userCredential?.user?.uid;
      if (userId == null) throw Exception('Authentication failed');

      // Check if user exists in database
      final existingUser = await _repository.getUserData(userId);

      if (existingUser != null) {
        // Existing user - load their data
        user.value = existingUser;
        _userCache = existingUser;
      } else {
        // New user - create profile
        final newUser = UserModel(
          id: userId,
          email: userCredential?.user?.email ?? '@xy.com',
          username: _generateUsername(userCredential?.user?.email ?? '@xy.com'),
          fullName: userCredential?.user?.displayName ?? 'EatRight User',
          profileUrl: userCredential?.user?.photoURL ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          preferences: UserPreferences.empty(),
          healthProfile: UserHealthProfile.empty(),
        );

        // Save new user to database
        await _repository.saveUserData(newUser);
        user.value = newUser;
        _userCache = newUser;
      }
    } catch (e) {
      errorMessage.value = 'Failed to handle user authentication: $e';
      print('Error handling user auth: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear user data (on logout)
  Future<void> clearUserData() async {
    user.value = UserModel.empty();
    _userCache = null;
  }
}
