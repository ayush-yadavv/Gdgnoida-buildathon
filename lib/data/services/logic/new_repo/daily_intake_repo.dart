import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
// import 'package:get/get.dart'; // Removed Get dependency from Repo
import 'package:shared_preferences/shared_preferences.dart';

class DailyIntakeRepository {
  // Removed static instance - Dependency should be injected
  // static DailyIntakeRepository get instance => Get.find();

  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  static const String _localPrefix = 'daily_intake_';

  // Inject dependencies
  DailyIntakeRepository(this._firestore, this._prefs);

  String getDateKey(DateTime date) {
    // Normalize date to ignore time component for consistent keying
    final dateOnly = DateTime(date.year, date.month, date.day);
    return '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
  }

  String _getStorageKey(String userId, DateTime date) {
    return '$_localPrefix${userId}_${getDateKey(date)}';
  }

  DocumentReference _getFirestoreDocRef(String userId, DateTime date) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(getDateKey(date)); // Use date key as document ID
  }

  /// Fetches DailyIntakeModel from local storage only.
  Future<DailyIntakeModel?> getLocalDailyIntake(
    String userId,
    DateTime date,
  ) async {
    final key = _getStorageKey(userId, date);
    final data = _prefs.getString(key);
    if (data != null) {
      try {
        return DailyIntakeModel.fromJson(jsonDecode(data));
      } catch (e) {
        print('Error decoding local intake for $key: $e');
        // Optionally remove invalid data
        // await _prefs.remove(key);
        return null;
      }
    }
    return null;
  }

  /// Fetches DailyIntakeModel from Firestore only.
  Future<DailyIntakeModel?> getRemoteDailyIntake(
    String userId,
    DateTime date,
  ) async {
    try {
      final docRef = _getFirestoreDocRef(userId, date);
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        // Ensure the ID in the model matches the document ID for consistency
        final data = doc.data()! as Map<String, dynamic>;
        data['id'] = doc.id; // Overwrite ID from Firestore doc ID
        return DailyIntakeModel.fromJson(data);
      }
      return null; // Return null if document doesn't exist
    } catch (e) {
      print('Error getting intake from Firestore for ${getDateKey(date)}: $e');
      // Don't rethrow, return null to indicate fetch failure
      return null;
    }
  }

  /// Saves DailyIntakeModel locally and attempts to save remotely.
  /// Local save is prioritized. Remote save failure is logged but doesn't throw.
  Future<void> saveDailyIntake(DailyIntakeModel intake) async {
    // 1. Validate: Ensure the model's ID matches the date key
    final expectedId = getDateKey(intake.date);
    if (intake.id != expectedId) {
      print(
        "Warning: DailyIntakeModel ID '${intake.id}' does not match expected date key '$expectedId'. Overwriting ID.",
      );
      // It's crucial the ID matches the intended Firestore document ID
      intake = intake.copyWith(id: expectedId);
    }

    // 2. Save locally first (synchronous SharedPreferences is fast)
    final key = _getStorageKey(intake.userId, intake.date);
    try {
      await _prefs.setString(key, jsonEncode(intake.toJson()));
      print("Saved intake locally for key: $key");
    } catch (e) {
      print("Error saving intake locally for key $key: $e");
      // Decide if this error is critical. Usually, local save should work.
      // If it fails, saving remotely might also be problematic.
      // Consider rethrowing if local save failure is unacceptable.
      rethrow; // Rethrow for now, controller needs to handle this potential failure
    }

    // 3. Attempt to save to Firestore asynchronously (fire and forget or handle future)
    // We don't await here to avoid blocking the UI flow
    _saveToFirestore(intake)
        .then((_) {
          print("Successfully saved intake to Firestore for ID: ${intake.id}");
        })
        .catchError((error) {
          // Log remote save errors, but don't necessarily crash the app
          // Implement more robust error handling/retry logic if needed (e.g., using a queue)
          print("Error saving intake to Firestore for ID ${intake.id}: $error");
        });
  }

  // Private helper for Firestore save
  Future<void> _saveToFirestore(DailyIntakeModel intake) async {
    final docRef = _getFirestoreDocRef(intake.userId, intake.date);
    // Use set with merge: true to create or update fields
    await docRef.set(intake.toJson(), SetOptions(merge: true));
  }

  /// Fetches multiple DailyIntakeModels from local storage.
  Future<List<DailyIntakeModel>> getLocalDailyIntakesForDates(
    String userId,
    List<DateTime> dates,
  ) async {
    List<DailyIntakeModel> results = [];
    for (final date in dates) {
      final intake = await getLocalDailyIntake(userId, date);
      // Add even if null to represent the day, or filter out? Filter for now.
      if (intake != null) {
        results.add(intake);
      }
    }
    return results;
  }

  /// Fetches multiple DailyIntakeModels from Firestore.
  Future<List<DailyIntakeModel>> getRemoteDailyIntakesForDates(
    String userId,
    List<DateTime> dates,
  ) async {
    // This could potentially be optimized with Firestore 'IN' query if needed,
    // but fetching individually is often acceptable for small ranges like a week.
    List<DailyIntakeModel> results = [];
    for (final date in dates) {
      final intake = await getRemoteDailyIntake(userId, date);
      if (intake != null) {
        results.add(intake);
      }
    }
    return results;
  }

  /// Saves multiple intakes locally. Used after fetching remote data.
  Future<void> saveLocalDailyIntakes(
    String userId,
    List<DailyIntakeModel> intakes,
  ) async {
    for (final intake in intakes) {
      // Ensure user ID matches if needed
      if (intake.userId == userId) {
        final key = _getStorageKey(userId, intake.date);
        try {
          await _prefs.setString(key, jsonEncode(intake.toJson()));
        } catch (e) {
          print(
            "Error saving intake locally for key $key during bulk save: $e",
          );
        }
      }
    }
  }
}
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DailyIntakeRepository {
//   static DailyIntakeRepository get instance => Get.find();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final SharedPreferences _prefs;
//   static const String _dailyIntakeKey = 'daily_intake_';
//   static const String _lastSyncKey = 'last_sync_';

//   DailyIntakeRepository(this._prefs);

//   // Get daily intake with offline-first approach
//   Future<DailyIntakeModel?> getDailyIntake(String userId, DateTime date) async {
//     try {
//       // Try to get from local storage first
//       final localData = await _getFromLocalStorage(userId, date);
//       if (localData != null) {
//         // Check if we need to sync with server
//         final lastSync = await _getLastSync(userId, date);
//         if (lastSync != null &&
//             DateTime.now().difference(lastSync) < const Duration(hours: 1)) {
//           return localData;
//         }
//       }

//       // Get from Firestore
//       final firestoreData = await _getFromFirestore(userId, date);
//       if (firestoreData != null) {
//         // Update local storage
//         await _saveToLocalStorage(userId, date, firestoreData);
//         await _updateLastSync(userId, date);
//         return firestoreData;
//       }

//       return localData;
//     } catch (e) {
//       print('Error getting daily intake: $e');
//       return null;
//     }
//   }

//   // Save daily intake with offline-first approach
//   Future<void> saveDailyIntake(DailyIntakeModel intake) async {
//     try {
//       // Save to local storage first
//       await _saveToLocalStorage(intake.userId, intake.date, intake);

//       // Then try to sync with Firestore
//       await _saveToFirestore(intake);
//       await _updateLastSync(intake.userId, intake.date);
//     } catch (e) {
//       print('Error saving daily intake: $e');
//       rethrow;
//     }
//   }

//   // Get weekly intake with offline-first approach
//   Future<List<DailyIntakeModel>> getWeeklyIntake(
//     String userId,
//     DateTime startDate,
//   ) async {
//     try {
//       final List<DailyIntakeModel> weeklyData = [];

//       // Get data for each day
//       for (int i = 0; i < 7; i++) {
//         final date = startDate.add(Duration(days: i));
//         final intake = await getDailyIntake(userId, date);
//         if (intake != null) {
//           weeklyData.add(intake);
//         }
//       }

//       return weeklyData;
//     } catch (e) {
//       print('Error getting weekly intake: $e');
//       return [];
//     }
//   }

//   // Local storage methods
//   Future<DailyIntakeModel?> _getFromLocalStorage(
//     String userId,
//     DateTime date,
//   ) async {
//     final key = _getStorageKey(userId, date);
//     final data = _prefs.getString(key);
//     if (data != null) {
//       return DailyIntakeModel.fromJson(jsonDecode(data));
//     }
//     return null;
//   }

//   Future<void> _saveToLocalStorage(
//     String userId,
//     DateTime date,
//     DailyIntakeModel intake,
//   ) async {
//     final key = _getStorageKey(userId, date);
//     await _prefs.setString(key, jsonEncode(intake.toJson()));
//   }

//   Future<DateTime?> _getLastSync(String userId, DateTime date) async {
//     final key = _getLastSyncKey(userId, date);
//     final timestamp = _prefs.getInt(key);
//     if (timestamp != null) {
//       return DateTime.fromMillisecondsSinceEpoch(timestamp);
//     }
//     return null;
//   }

//   Future<void> _updateLastSync(String userId, DateTime date) async {
//     final key = _getLastSyncKey(userId, date);
//     await _prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
//   }

//   // Firestore methods
//   Future<DailyIntakeModel?> _getFromFirestore(
//     String userId,
//     DateTime date,
//   ) async {
//     try {
//       final docRef = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('daily_intake')
//           .doc(_getDateKey(date));

//       final doc = await docRef.get();
//       if (doc.exists) {
//         return DailyIntakeModel.fromJson(doc.data()!);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting from Firestore: $e');
//       return null;
//     }
//   }

//   Future<void> _saveToFirestore(DailyIntakeModel intake) async {
//     try {
//       final docRef = _firestore
//           .collection('users')
//           .doc(intake.userId)
//           .collection('daily_intake')
//           .doc(_getDateKey(intake.date));

//       await docRef.set(intake.toJson(), SetOptions(merge: true));
//     } catch (e) {
//       print('Error saving to Firestore: $e');
//       rethrow;
//     }
//   }

//   // Helper methods
//   String _getStorageKey(String userId, DateTime date) =>
//       '$_dailyIntakeKey${userId}_${_getDateKey(date)}';

//   String _getLastSyncKey(String userId, DateTime date) =>
//       '$_lastSyncKey${userId}_${_getDateKey(date)}';

//   String _getDateKey(DateTime date) =>
//       '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
// }
