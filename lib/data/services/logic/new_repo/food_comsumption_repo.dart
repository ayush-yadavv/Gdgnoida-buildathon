import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:get/get.dart'; // Assuming GetX is used for SharedPreferences dependency
import 'package:shared_preferences/shared_preferences.dart';

class FoodConsumptionRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  // FoodConsumptionRepository(this._prefs);

  // FoodConsumptionRepository();
  static const String _localPrefix = 'food_consumption_';
  static const String _lastSyncPrefix = 'food_sync_';
  // Define how often to consider local data stale (e.g., 1 hour)
  static const Duration _staleDuration = Duration(hours: 1);

  // Inject dependencies
  FoodConsumptionRepository(this._firestore, this._prefs);

  // Static instance (ensure dependencies are registered with GetX)
  // static FoodConsumptionRepository get instance {
  //   try {
  //     return FoodConsumptionRepository(
  //       FirebaseFirestore.instance,
  //       Get.find<SharedPreferences>(),
  //     );
  //   } catch (e) {
  //     print("Error creating FoodConsumptionRepository instance: $e");
  //     rethrow;
  //   }
  // }

  // --- Key Helpers ---
  String _getLocalStorageKey(String userId, String consumptionId) =>
      '$_localPrefix${userId}_$consumptionId';
  String _getLastSyncKey(String userId, String consumptionId) =>
      '$_lastSyncPrefix${userId}_$consumptionId';

  // --- Firestore Path Helper ---
  CollectionReference _getUserConsumptionCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('food_consumption');
  DocumentReference _getConsumptionDocRef(
    String userId,
    String consumptionId,
  ) => _getUserConsumptionCollection(userId).doc(consumptionId);

  // --- Local Storage Operations ---
  Future<FoodConsumptionModel?> _getLocalConsumptionById(
    String userId,
    String consumptionId,
  ) async {
    final key = _getLocalStorageKey(userId, consumptionId);
    final data = _prefs.getString(key);
    if (data != null) {
      try {
        return FoodConsumptionModel.fromJson(jsonDecode(data));
      } catch (e) {
        print("Error decoding local consumption $consumptionId: $e");
        await _prefs.remove(key); // Remove corrupted data
        return null;
      }
    }
    return null;
  }

  Future<void> _saveLocalConsumption(FoodConsumptionModel consumption) async {
    final key = _getLocalStorageKey(consumption.userId, consumption.id);
    try {
      await _prefs.setString(key, jsonEncode(consumption.toJson()));
    } catch (e) {
      print("Error saving consumption locally $key: $e");
      // Don't rethrow here, allow remote save attempt
    }
  }

  Future<void> _removeLocalConsumption(
    String userId,
    String consumptionId,
  ) async {
    final key = _getLocalStorageKey(userId, consumptionId);
    try {
      await _prefs.remove(key);
      await _prefs.remove(
        _getLastSyncKey(userId, consumptionId),
      ); // Also remove sync time
    } catch (e) {
      print("Error removing local consumption $key: $e");
    }
  }

  // --- Sync Time Operations ---
  Future<DateTime?> _getLastSyncTime(
    String userId,
    String consumptionId,
  ) async {
    final key = _getLastSyncKey(userId, consumptionId);
    final timestamp = _prefs.getInt(key);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> _updateLastSyncTime(String userId, String consumptionId) async {
    final key = _getLastSyncKey(userId, consumptionId);
    try {
      await _prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print("Error updating sync time for $key: $e");
    }
  }

  // --- Firestore Operations ---
  Future<FoodConsumptionModel?> _getRemoteConsumptionById(
    String userId,
    String consumptionId,
  ) async {
    try {
      final docRef = _getConsumptionDocRef(userId, consumptionId);
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()! as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID from Firestore
        data['userId'] = userId; // Ensure userId is present
        return FoodConsumptionModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error fetching remote consumption $consumptionId: $e");
      return null; // Indicate fetch failure
    }
  }

  Future<void> _saveRemoteConsumption(FoodConsumptionModel consumption) async {
    final docRef = _getConsumptionDocRef(consumption.userId, consumption.id);
    // Use set without merge for individual consumption items
    await docRef.set(consumption.toJson());
    await _updateLastSyncTime(
      consumption.userId,
      consumption.id,
    ); // Update sync time on successful save
  }

  Future<void> _deleteRemoteConsumption(
    String userId,
    String consumptionId,
  ) async {
    final docRef = _getConsumptionDocRef(userId, consumptionId);
    await docRef.delete();
  }

  // --- Public API Methods (Offline-First) ---

  /// Saves locally immediately, then attempts remote save asynchronously.
  Future<void> saveFoodConsumption(FoodConsumptionModel consumption) async {
    if (consumption.userId.isEmpty || consumption.id.isEmpty) {
      throw ArgumentError("User ID and Consumption ID are required.");
    }

    // 1. Save locally first
    await _saveLocalConsumption(consumption);
    print("Saved consumption locally: ${consumption.id}");

    // 2. Attempt remote save (fire and forget or handle future)
    _saveRemoteConsumption(consumption)
        .then((_) {
          print(
            "Successfully synced consumption to Firestore: ${consumption.id}",
          );
        })
        .catchError((error) {
          print(
            "Error syncing consumption ${consumption.id} to Firestore: $error",
          );
          // TODO: Implement retry mechanism or offline queue if needed
        });
  }

  /// Fetches consumptions by IDs, prioritizing local cache and syncing stale data.
  Future<List<FoodConsumptionModel>> getFoodConsumptionsByIds(
    String userId,
    List<String> consumptionIds, {
    bool forceRemote = false, // Force fetch from Firestore
  }) async {
    if (userId.isEmpty) throw ArgumentError("User ID cannot be empty.");
    if (consumptionIds.isEmpty) return [];

    Map<String, FoodConsumptionModel> resultsMap = {};
    List<String> idsToFetchRemotely = [];
    final now = DateTime.now();

    // 1. Check local storage and sync status
    for (final id in consumptionIds.toSet()) {
      // Use toSet to avoid duplicate checks/fetches
      if (id.isEmpty) continue;

      if (forceRemote) {
        idsToFetchRemotely.add(id);
        continue;
      }

      final localItem = await _getLocalConsumptionById(userId, id);
      if (localItem != null) {
        final lastSync = await _getLastSyncTime(userId, id);
        // Check if local data is recent enough or sync time is missing
        if (lastSync == null || now.difference(lastSync) > _staleDuration) {
          idsToFetchRemotely.add(id); // Mark as stale, needs remote check
          resultsMap[id] =
              localItem; // Keep local item for now, will be replaced if remote is newer
        } else {
          resultsMap[id] = localItem; // Local is fresh enough
        }
      } else {
        idsToFetchRemotely.add(id); // Missing locally, must fetch
      }
    }

    // 2. Fetch missing/stale items from Firestore
    if (idsToFetchRemotely.isNotEmpty) {
      print(
        "Fetching/Syncing ${idsToFetchRemotely.length} consumption items remotely...",
      );
      final List<Future<FoodConsumptionModel?>> remoteFetchFutures = [];
      for (final id in idsToFetchRemotely) {
        remoteFetchFutures.add(_getRemoteConsumptionById(userId, id));
      }

      try {
        final remoteResults = await Future.wait(remoteFetchFutures);
        List<FoodConsumptionModel> updatedLocally = [];

        for (int i = 0; i < idsToFetchRemotely.length; i++) {
          final id = idsToFetchRemotely[i];
          final remoteItem = remoteResults[i];
          final currentItemInMap = resultsMap[id]; // Might be stale local data

          if (remoteItem != null) {
            // Update map if remote is newer or if item wasn't in map before
            if (currentItemInMap == null ||
                remoteItem.updatedAt.isAfter(currentItemInMap.updatedAt)) {
              resultsMap[id] = remoteItem;
              updatedLocally.add(remoteItem); // Mark for local save
              await _updateLastSyncTime(userId, id); // Update sync time
            } else {
              // Remote is older or same, keep the version already in map (which was local)
              // Ensure sync time is updated if we fetched remotely, even if data wasn't newer
              await _updateLastSyncTime(userId, id);
            }
          } else {
            // Not found remotely. If it existed locally, remove it locally.
            if (currentItemInMap != null) {
              print("Item $id not found remotely, removing from local cache.");
              resultsMap.remove(id);
              await _removeLocalConsumption(userId, id);
            }
            // If it didn't exist locally either, do nothing.
          }
        }
        // Bulk save updated items to local storage
        if (updatedLocally.isNotEmpty) {
          await _saveLocalConsumptions(userId, updatedLocally); // New helper
        }
      } catch (e) {
        print("Error during remote fetch batch for consumptions: $e");
        // Proceed with potentially stale local data present in resultsMap
      }
    }

    // 3. Return results sorted
    final finalResults = resultsMap.values.toList();
    finalResults.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    return finalResults;
  }

  /// Helper to save multiple consumptions locally
  Future<void> _saveLocalConsumptions(
    String userId,
    List<FoodConsumptionModel> consumptions,
  ) async {
    for (final item in consumptions) {
      if (item.userId == userId) {
        // Ensure correct user
        await _saveLocalConsumption(item);
      }
    }
  }

  /// Fetches a single consumption item with offline-first strategy.
  Future<FoodConsumptionModel?> getFoodConsumptionById(
    String userId,
    String consumptionId, {
    bool forceRemote = false,
  }) async {
    if (userId.isEmpty || consumptionId.isEmpty) return null;

    FoodConsumptionModel? finalResult;
    bool needsRemoteFetch = forceRemote;

    if (!forceRemote) {
      finalResult = await _getLocalConsumptionById(userId, consumptionId);
      if (finalResult != null) {
        final lastSync = await _getLastSyncTime(userId, consumptionId);
        if (lastSync == null ||
            DateTime.now().difference(lastSync) > _staleDuration) {
          needsRemoteFetch = true; // Stale, need to check remote
        }
      } else {
        needsRemoteFetch = true; // Missing locally
      }
    }

    if (needsRemoteFetch) {
      try {
        final remoteItem = await _getRemoteConsumptionById(
          userId,
          consumptionId,
        );
        if (remoteItem != null) {
          // Update local cache and sync time only if remote is newer or local didn't exist
          if (finalResult == null ||
              remoteItem.updatedAt.isAfter(finalResult.updatedAt)) {
            await _saveLocalConsumption(remoteItem);
            finalResult = remoteItem;
          }
          await _updateLastSyncTime(
            userId,
            consumptionId,
          ); // Update sync time regardless
        } else {
          // Remote not found, if local existed, remove it
          if (finalResult != null) {
            await _removeLocalConsumption(userId, consumptionId);
            finalResult = null; // Clear the result
          }
        }
      } catch (e) {
        print("Error fetching remote single consumption $consumptionId: $e");
        // Return potentially stale local data if fetch failed
      }
    }
    return finalResult;
  }

  /// Deletes locally and attempts remote deletion asynchronously.
  Future<void> deleteFoodConsumption(
    String userId,
    String consumptionId,
  ) async {
    if (userId.isEmpty || consumptionId.isEmpty) {
      throw ArgumentError("IDs required for deletion.");
    }

    // 1. Delete locally first
    await _removeLocalConsumption(userId, consumptionId);
    print("Removed consumption locally: $consumptionId");

    // 2. Attempt remote deletion
    _deleteRemoteConsumption(userId, consumptionId)
        .then((_) {
          print(
            "Successfully deleted consumption from Firestore: $consumptionId",
          );
        })
        .catchError((error) {
          print(
            "Error deleting consumption $consumptionId from Firestore: $error",
          );
          // TODO: Handle failed remote delete (e.g., mark for later deletion)
        });
  }
}

// Helper extension for GetX DI remains the same
extension SharedPreferencesGetX on GetInterface {
  Future<SharedPreferences> get sharedPreferences async =>
      await SharedPreferences.getInstance();
}
