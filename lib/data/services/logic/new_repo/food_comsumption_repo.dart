import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:get_storage/get_storage.dart';

class FoodConsumptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  static const String _localPrefix = 'food_consumption_';
  static const String _lastSyncPrefix = 'food_sync_';
  static const Duration _staleDuration = Duration(hours: 1);

  // --- Key Helpers ---
  String _getLocalStorageKey(String userId, String consumptionId) =>
      '$_localPrefix${userId}_$consumptionId';

  String _getLastSyncKey(String userId, String consumptionId) =>
      '$_lastSyncPrefix${userId}_$consumptionId';

  // --- Local Storage Methods ---
  Future<FoodConsumptionModel?> _getFromLocalStorage(
    String userId,
    String consumptionId,
  ) async {
    try {
      final key = _getLocalStorageKey(userId, consumptionId);
      final lastSyncKey = _getLastSyncKey(userId, consumptionId);

      // Check if local data is stale
      final lastSyncString = _storage.read<String>(lastSyncKey);
      if (lastSyncString != null) {
        final lastSync = DateTime.parse(lastSyncString);
        if (DateTime.now().difference(lastSync) > _staleDuration) {
          return null; // Data is stale
        }
      }

      final jsonString = _storage.read<String>(key);
      if (jsonString == null) return null;

      return FoodConsumptionModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error in _getFromLocalStorage: $e');
      return null;
    }
  }

  Future<void> _saveToLocalStorage(FoodConsumptionModel consumption) async {
    try {
      final key = _getLocalStorageKey(consumption.userId, consumption.id);
      await _storage.write(key, jsonEncode(consumption.toJson()));
      await _storage.write(
        _getLastSyncKey(consumption.userId, consumption.id),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error in _saveToLocalStorage: $e');
      rethrow;
    }
  }

  Future<void> _removeLocalConsumption(
    String userId,
    String consumptionId,
  ) async {
    try {
      final key = _getLocalStorageKey(userId, consumptionId);
      await GetStorage().remove(key);
      await _storage.remove(_getLastSyncKey(userId, consumptionId));
    } catch (e) {
      print('Error in _removeLocalConsumption: $e');
      rethrow;
    }
  }

  // --- Firestore Path Helper ---
  CollectionReference _getUserConsumptionCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('food_consumption');

  DocumentReference _getConsumptionDocRef(
    String userId,
    String consumptionId,
  ) => _getUserConsumptionCollection(userId).doc(consumptionId);

  /// Fetches all food consumptions for a user within a specific date range
  Future<List<FoodConsumptionModel>> getConsumptionsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    required String userId,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      // Convert dates to start and end of day for proper range query
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = endDate.add(const Duration(days: 1));

      final querySnapshot = await _getUserConsumptionCollection(userId)
          .where('consumedAt', isGreaterThanOrEqualTo: start)
          .where('consumedAt', isLessThan: end)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => FoodConsumptionModel.fromJson(
              doc.data() as Map<String, dynamic>..['id'] = doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error in getConsumptionsForDateRange: $e');
      rethrow;
    }
  }

  // --- Local Storage Operations ---
  Future<FoodConsumptionModel?> _getLocalConsumptionById(
    String userId,
    String consumptionId,
  ) async {
    try {
      return await _getFromLocalStorage(userId, consumptionId);
    } catch (e) {
      print('Error in _getLocalConsumptionById: $e');
      return null;
    }
  }

  // Future<void> _saveToLocalStorage(FoodConsumptionModel consumption) async {
  //   final key = _getLocalStorageKey(consumption.userId, consumption.id);
  //   await _storage.write(key, jsonEncode(consumption.toJson()));
  //   await _storage.write(
  //     _getLastSyncKey(consumption.userId, consumption.id),
  //     DateTime.now().toIso8601String(),
  //   );
  // }

  // Future<void> _removeLocalConsumption(
  //   String userId,
  //   String consumptionId,
  // ) async {
  //   final key = _getLocalStorageKey(userId, consumptionId);
  //   try {
  //     await _storage.remove(key);
  //     await _storage.remove(
  //       _getLastSyncKey(userId, consumptionId),
  //     ); // Also remove sync time
  //   } catch (e) {
  //     print("Error removing local consumption $key: $e");
  //   }
  // }

  // --- Sync Time Operations ---
  Future<DateTime?> _getLastSyncTime(
    String userId,
    String consumptionId,
  ) async {
    final key = _getLastSyncKey(userId, consumptionId);
    final timestamp = GetStorage().read<String>(key);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> _updateLastSyncTime(String userId, String consumptionId) async {
    final key = _getLastSyncKey(userId, consumptionId);
    try {
      await GetStorage().write(key, DateTime.now().toIso8601String());
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
      final doc = await _getConsumptionDocRef(userId, consumptionId).get();
      if (doc.exists) {
        return FoodConsumptionModel.fromJson(
          doc.data() as Map<String, dynamic>..['id'] = doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error in _getRemoteConsumptionById: $e');
      rethrow;
    }
  }

  Future<void> _saveRemoteConsumption(FoodConsumptionModel consumption) async {
    try {
      await _getConsumptionDocRef(
        consumption.userId,
        consumption.id,
      ).set(consumption.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error in _saveRemoteConsumption: $e');
      rethrow;
    }
  }

  Future<void> _deleteRemoteConsumption(
    String userId,
    String consumptionId,
  ) async {
    try {
      await _getConsumptionDocRef(userId, consumptionId).delete();
    } catch (e) {
      print('Error in _deleteRemoteConsumption: $e');
      rethrow;
    }
  }

  // --- Public API Methods (Offline-First) ---

  /// Saves locally immediately, then attempts remote save asynchronously.
  Future<void> saveFoodConsumption(FoodConsumptionModel consumption) async {
    try {
      // Save locally first for immediate UI update
      await _saveToLocalStorage(consumption);

      // Then save to Firestore in background
      _saveRemoteConsumption(consumption).catchError((e) {
        print('Background save to Firestore failed: $e');
        // TODO: Implement retry mechanism
      });
    } catch (e) {
      print('Error in saveFoodConsumption: $e');
      rethrow;
    }
  }

  /// Fetches consumptions by IDs, prioritizing local cache and syncing stale data.
  Future<List<FoodConsumptionModel>> getFoodConsumptionsByIds(
    String userId,
    List<String> consumptionIds, {
    bool forceRemote = false,
  }) async {
    try {
      final results = <FoodConsumptionModel>[];
      final missingIds = <String>[];

      // First try to get from local storage
      if (!forceRemote) {
        for (final id in consumptionIds) {
          final local = await _getLocalConsumptionById(userId, id);
          if (local != null) {
            results.add(local);
          } else {
            missingIds.add(id);
          }
        }

        // If we found all items locally, return them
        if (missingIds.isEmpty) return results;
      } else {
        missingIds.addAll(consumptionIds);
      }

      // Get remaining items from Firestore
      final docs = await _getUserConsumptionCollection(
        userId,
      ).where(FieldPath.documentId, whereIn: missingIds).get();

      // Process and cache results
      for (final doc in docs.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final consumption = FoodConsumptionModel.fromJson(data);
        results.add(consumption);
        await _saveToLocalStorage(consumption);
      }

      return results;
    } catch (e) {
      print('Error in getFoodConsumptionsByIds: $e');
      rethrow;
    }
  }

  /// Fetches a single consumption item with offline-first strategy.
  Future<FoodConsumptionModel?> getFoodConsumptionById(
    String userId,
    String consumptionId, {
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final local = await _getLocalConsumptionById(userId, consumptionId);
        if (local != null) return local;
      }

      return await _getRemoteConsumptionById(userId, consumptionId);
    } catch (e) {
      print('Error in getFoodConsumptionById: $e');
      return null;
    }
  }

  /// Deletes locally and attempts remote deletion asynchronously.
  Future<void> deleteFoodConsumption(
    String userId,
    String consumptionId,
  ) async {
    try {
      // Delete locally first
      await _removeLocalConsumption(userId, consumptionId);

      // Then delete from Firestore in background
      _deleteRemoteConsumption(userId, consumptionId).catchError((e) {
        print('Background delete from Firestore failed: $e');
        // TODO: Implement retry mechanism
      });
    } catch (e) {
      print('Error in deleteFoodConsumption: $e');
      rethrow;
    }
  }
}
