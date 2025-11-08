import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  static const String _userKey = 'user_';
  static const String _lastSyncKey = 'user_sync_';

  UserRepository(this._prefs);

  // Get user data with offline-first approach
  Future<UserModel?> getUserData(String userId) async {
    try {
      // Try to get from local storage first
      final localData = await _getFromLocalStorage(userId);
      if (localData != null) {
        // Check if we need to sync with server
        final lastSync = await _getLastSync(userId);
        if (lastSync != null &&
            DateTime.now().difference(lastSync) < const Duration(hours: 1)) {
          return localData;
        }
      }

      // Get from Firestore
      final firestoreData = await _getFromFirestore(userId);
      if (firestoreData != null) {
        // Update local storage
        await _saveToLocalStorage(userId, firestoreData);
        await _updateLastSync(userId);
        return firestoreData;
      }

      return localData;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Save user data with offline-first approach
  Future<void> saveUserData(UserModel user) async {
    try {
      // Save to local storage first
      await _saveToLocalStorage(user.id, user);

      // Then try to sync with Firestore
      await _saveToFirestore(user);
      await _updateLastSync(user.id);
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Check username availability
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('Users')
              .where('username', isEqualTo: username)
              .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Update single user field
  Future<void> updateUserField(String userId, Map<String, dynamic> data) async {
    try {
      // Update Firestore
      await _firestore.collection('Users').doc(userId).update(data);

      // Update local storage if exists
      final localData = await _getFromLocalStorage(userId);
      if (localData != null) {
        final updatedData = localData.toJson()..addAll(data);
        await _saveToLocalStorage(userId, UserModel.fromJson(updatedData));
      }
    } catch (e) {
      print('Error updating user field: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(
        'Users/Images/Profile/$userId/${DateTime.now().millisecondsSinceEpoch}',
      );

      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      // Update user profile URL
      await updateUserField(userId, {'profileUrl': url});

      return url;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Local storage methods
  Future<UserModel?> _getFromLocalStorage(String userId) async {
    final key = _getStorageKey(userId);
    final data = _prefs.getString(key);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> _saveToLocalStorage(String userId, UserModel user) async {
    final key = _getStorageKey(userId);
    await _prefs.setString(key, jsonEncode(user.toJson()));
  }

  Future<DateTime?> _getLastSync(String userId) async {
    final key = _getLastSyncKey(userId);
    final timestamp = _prefs.getInt(key);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> _updateLastSync(String userId) async {
    final key = _getLastSyncKey(userId);
    await _prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  // Firestore methods
  Future<UserModel?> _getFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error getting from Firestore: $e');
      return null;
    }
  }

  Future<void> _saveToFirestore(UserModel user) async {
    try {
      await _firestore.collection('Users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error saving to Firestore: $e');
      rethrow;
    }
  }

  // Helper methods
  String _getStorageKey(String userId) => '$_userKey$userId';
  String _getLastSyncKey(String userId) => '$_lastSyncKey$userId';
}
