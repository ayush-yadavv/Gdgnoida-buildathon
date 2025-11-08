import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:eat_right/data/services/logic/new_repo/daily_intake_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyIntakeController extends GetxController {
  static DailyIntakeController get instance => Get.find();

  // ... (Dependencies and State remain the same) ...
  late final DailyIntakeRepository _repository;
  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final RxMap<String, DailyIntakeModel> _dailyIntakeCache =
      RxMap<String, DailyIntakeModel>();

  // --- Public Reactive Getters for UI ---
  DateTime get selectedDate => _selectedDate.value;

  DailyIntakeModel? get currentDailyIntake {
    // ... (implementation remains the same) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return null;
    final cacheKey = _getCacheKey(userId, _selectedDate.value);
    return _dailyIntakeCache[cacheKey];
  }

  List<DailyIntakeModel> get weeklyIntakeData {
    // ... (implementation remains the same) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return [];

    final weekDates = _getCurrentWeekDates(_selectedDate.value);
    List<DailyIntakeModel> weekData = [];
    for (final date in weekDates) {
      final cacheKey = _getCacheKey(userId, date);
      if (_dailyIntakeCache.containsKey(cacheKey)) {
        weekData.add(_dailyIntakeCache[cacheKey]!);
      } else {
        // Use the constructor requiring date and userId for empty models
        weekData.add(DailyIntakeModel.empty());
      }
    }
    weekData.sort((a, b) => a.date.compareTo(b.date));
    return weekData;
  }

  // --- Initialization ---
  // Rx variable to track auth state
  final Rx<User?> _currentUser = Rx<User?>(null);

  @override
  void onInit() async {
    super.onInit();
    final prefs = await SharedPreferences.getInstance();
    _repository = DailyIntakeRepository(FirebaseFirestore.instance, prefs);

    // Listen to auth state changes
    _authRepo.onAuthStateChanged.listen((user) {
      _currentUser.value = user;
      _handleAuthStateChange(user);
    });

    // Initial auth state
    _handleAuthStateChange(_authRepo.currentUser);

    // Listen to date changes
    ever(_selectedDate, (_) => _loadDataForSelectedDate());
  }

  void _handleAuthStateChange(dynamic user) {
    // ... (implementation remains the same) ...
    if (user != null) {
      print("User authenticated, loading initial data...");
      _loadDataForSelectedDate();
      _loadDataForWeek(_selectedDate.value);
    } else {
      print("User logged out, clearing data...");
      _clearLocalData();
    }
  }

  void _clearLocalData() {
    // ... (implementation remains the same) ...
    isLoading.value = false;
    errorMessage.value = '';
    _dailyIntakeCache.clear();
  }

  // --- Public Actions ---
  void selectDate(DateTime newDate) {
    // ... (implementation remains the same) ...
    final normalizedDate = DateTime(newDate.year, newDate.month, newDate.day);
    if (_selectedDate.value != normalizedDate) {
      print("Selected date changed to: ${normalizedDate.toIso8601String()}");
      _selectedDate.value = normalizedDate;
    }
  }

  Future<void> addFoodConsumption(FoodConsumptionModel consumption) async {
    // ... (implementation remains the same) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) {
      errorMessage.value = 'User not authenticated.';
      print(errorMessage.value);
      return;
    }

    // Setting loading state specific to this action might be better
    // than using the global isLoading if multiple async actions can happen
    // final RxBool isAdding = true.obs; // Example local loading state
    isLoading.value = true; // Using global for now
    errorMessage.value = '';

    try {
      final consumptionDate = DateTime(
        consumption.consumedAt.year,
        consumption.consumedAt.month,
        consumption.consumedAt.day,
      );
      final cacheKey = _getCacheKey(userId, consumptionDate);

      // Use the new helper method to ensure data is loaded/fetched
      DailyIntakeModel intakeToUpdate = await fetchIntakeForDate(
        consumptionDate,
      );

      final newTotalNutrients = _calculateTotalNutrients(
        intakeToUpdate.totalNutrients,
        consumption,
      );
      final newMealBreakdown = _updateMealTypeBreakdown(
        intakeToUpdate.mealTypeBreakdown,
        consumption,
      );
      final newFoodIds = [...intakeToUpdate.foodIds, consumption.id];
      final expectedId = _repository.getDateKey(consumptionDate);

      final updatedIntake = DailyIntakeModel(
        id: expectedId,
        userId: userId,
        date: consumptionDate,
        totalNutrients: newTotalNutrients,
        foodIds: newFoodIds,
        mealTypeBreakdown: newMealBreakdown,
        createdAt: intakeToUpdate.createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.saveDailyIntake(updatedIntake);
      _dailyIntakeCache[cacheKey] = updatedIntake; // Update cache directly
      print("Updated cache for $cacheKey after adding consumption.");
    } catch (e) {
      errorMessage.value = 'Failed to add food consumption: $e';
      print('Error adding food consumption: $e');
    } finally {
      isLoading.value = false;
      // isAdding.value = false;
    }
  }

  Future<void> refreshCurrentDateData() async {
    // ... (implementation remains the same) ...
    await _fetchAndUpdateCache(_selectedDate.value);
  }

  Future<void> refreshWeekData() async {
    // ... (implementation remains the same) ...
    await _loadDataForWeek(_selectedDate.value, forceRemote: true);
  }

  // --- NEW PUBLIC HELPERS ---

  /// Synchronously gets the cached DailyIntakeModel for a given date, if available.
  /// Returns null if not in cache. Does not trigger fetching.
  DailyIntakeModel? getDailyIntakeForDate(DateTime date) {
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return null;
    final cacheKey = _getCacheKey(userId, date);
    return _dailyIntakeCache[cacheKey];
  }

  /// Asynchronously ensures the DailyIntakeModel for a given date is loaded
  /// (from cache or fetched) and returns it. Updates the cache.
  Future<DailyIntakeModel> fetchIntakeForDate(DateTime date) async {
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) {
      print("Cannot fetch intake: User not authenticated.");
      // Return an empty model specific to the date
      return DailyIntakeModel.empty();
    }
    final cacheKey = _getCacheKey(userId, date);
    // Check cache first
    if (_dailyIntakeCache.containsKey(cacheKey)) {
      return _dailyIntakeCache[cacheKey]!;
    }
    // If not in cache, fetch using the existing logic
    return await _fetchAndUpdateCache(date);
  }

  // --- Private Loading and Helper Methods ---

  Future<void> _loadDataForSelectedDate() async {
    // ... (implementation remains the same) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return;

    final date = _selectedDate.value;
    final cacheKey = _getCacheKey(userId, date);

    if (!_dailyIntakeCache.containsKey(cacheKey)) {
      print("Data for selected date $date not in cache. Fetching...");
      await _fetchAndUpdateCache(date); // This updates the cache
    } else {
      print("Data for selected date $date already in cache.");
      // Optionally trigger background refresh ONLY if needed (e.g., data is stale)
      // This avoids unnecessary fetches if data was just loaded by another process
      // Consider adding a timestamp check here before calling _fetchAndUpdateCache
    }
  }

  Future<DailyIntakeModel> _fetchAndUpdateCache(DateTime date) async {
    // ... (implementation remains the same - this is the core fetch logic) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) {
      // Return an empty model specific to the date
      return DailyIntakeModel.empty();
    }

    // Use a local loading state for this specific fetch if desired,
    // or rely on the global isLoading if acceptable.
    isLoading.value = true; // Using global for simplicity
    final cacheKey = _getCacheKey(userId, date);
    print("Fetching data for cache key: $cacheKey");

    // 1. Get local data first
    DailyIntakeModel? localData = await _repository.getLocalDailyIntake(
      userId,
      date,
    );
    final initialData = localData ?? DailyIntakeModel.empty();

    // Update cache immediately with local/empty data to trigger UI updates if needed
    // Avoid replacing newer cache data with older local data
    if (!_dailyIntakeCache.containsKey(cacheKey) ||
        localData == null ||
        localData.updatedAt.isAfter(_dailyIntakeCache[cacheKey]!.updatedAt)) {
      _dailyIntakeCache[cacheKey] = initialData;
    }

    // 2. Fetch remote data in the background
    DailyIntakeModel? remoteData; // Declare outside try
    try {
      remoteData = await _repository.getRemoteDailyIntake(userId, date);

      bool shouldUpdateCache = false;
      if (remoteData != null) {
        // Determine if cache needs update: remote exists and is newer than current cache value
        final currentCached = _dailyIntakeCache[cacheKey];
        shouldUpdateCache =
            (currentCached == null ||
            remoteData.updatedAt.isAfter(currentCached.updatedAt));

        if (shouldUpdateCache) {
          print(
            "Remote data for $date is newer. Updating local storage and cache.",
          );
          // Save remote data to local storage for offline persistence
          await _repository.saveLocalDailyIntakes(userId, [remoteData]);
          // Update the reactive cache
          _dailyIntakeCache[cacheKey] = remoteData;
        } else {
          print(
            "Remote data for $date is not newer. Cache not updated from remote.",
          );
        }
      } else {
        // Remote doesn't exist. If local existed, keep it. If neither exist, cache remains empty model.
        print("Remote data doesn't exist for $date.");
        if (localData == null && !_dailyIntakeCache.containsKey(cacheKey)) {
          _dailyIntakeCache[cacheKey] =
              DailyIntakeModel.empty(); // Ensure empty state is cached
        }
      }
    } catch (e) {
      print("Error fetching remote data for $date: $e");
      // Don't update global error if local data exists? Optional.
      if (_dailyIntakeCache[cacheKey]?.id.isEmpty ?? true) {
        // Only set error if we truly have no data
        errorMessage.value = "Couldn't sync with cloud for $date.";
      }
    } finally {
      isLoading.value = false;
    }

    // Return the current value in the cache (which is the most up-to-date we have)
    return _dailyIntakeCache[cacheKey] ?? DailyIntakeModel.empty();
  }

  Future<DailyIntakeModel> _getOrLoadIntakeForDate(
    String userId,
    DateTime date,
  ) async {
    // Simplified: just call fetchIntakeForDate which handles cache check
    return await fetchIntakeForDate(date);
  }

  Future<void> _loadDataForWeek(
    DateTime dateInWeek, {
    bool forceRemote = false,
  }) async {
    // ... (implementation remains the same) ...
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    final weekDates = _getCurrentWeekDates(dateInWeek);
    List<Future> fetchJobs = [];

    if (forceRemote) {
      print("Force refreshing week data from remote...");
      try {
        final remoteIntakes = await _repository.getRemoteDailyIntakesForDates(
          userId,
          weekDates,
        );
        await _repository.saveLocalDailyIntakes(userId, remoteIntakes);

        // Update cache directly from fetched remote data
        final remoteIntakesMap = {
          for (var intake in remoteIntakes) intake.date: intake,
        };
        for (final date in weekDates) {
          final cacheKey = _getCacheKey(userId, date);
          _dailyIntakeCache[cacheKey] =
              remoteIntakesMap[date] ?? DailyIntakeModel.empty();
        }
        print("Force remote refresh complete for week of $dateInWeek.");
      } catch (e) {
        print("Error during force remote week refresh: $e");
        errorMessage.value = "Failed to refresh week data from cloud.";
        // Fallback: load missing days individually (will use cache first)
        for (final date in weekDates) {
          fetchJobs.add(fetchIntakeForDate(date));
        }
        await Future.wait(fetchJobs);
      }
    } else {
      print("Loading week data (cache first) for week of $dateInWeek...");
      for (final date in weekDates) {
        final cacheKey = _getCacheKey(userId, date);
        if (!_dailyIntakeCache.containsKey(cacheKey)) {
          fetchJobs.add(fetchIntakeForDate(date)); // Ensures fetch/cache update
        }
      }
      if (fetchJobs.isNotEmpty) {
        await Future.wait(fetchJobs);
        print("Finished loading missing days for week of $dateInWeek.");
      } else {
        print("All data for week of $dateInWeek already in cache.");
      }
    }
    isLoading.value = false;
  }

  // --- Calculation Helpers ---
  Map<String, double> _calculateTotalNutrients(
    Map<String, double> currentNutrients,
    FoodConsumptionModel consumption,
  ) {
    // ... (implementation remains the same) ...
    final Map<String, double> result = Map.from(currentNutrients);
    result['calories'] = (result['calories'] ?? 0) + consumption.totalCalories;
    result['protein'] = (result['protein'] ?? 0) + consumption.totalProtein;
    result['fat'] = (result['fat'] ?? 0) + consumption.totalFat;
    result['carbohydrates'] =
        (result['carbohydrates'] ?? 0) + consumption.totalCarbohydrates;
    result['fiber'] = (result['fiber'] ?? 0) + consumption.totalFiber;

    for (var item in consumption.consumedItems) {
      item.otherConsumedMacros.forEach((key, quantity) {});
    }
    return result;
  }

  Map<String, double> _updateMealTypeBreakdown(
    Map<String, double> currentBreakdown,
    FoodConsumptionModel consumption,
  ) {
    // ... (implementation remains the same) ...
    final Map<String, double> result = Map.from(currentBreakdown);
    final mealType = _inferMealType(consumption.consumedAt);
    result[mealType] = (result[mealType] ?? 0) + consumption.totalCalories;
    return result;
  }

  String _inferMealType(DateTime consumedAt) {
    // ... (implementation remains the same) ...
    final hour = consumedAt.hour;
    if (hour >= 4 && hour < 11) return 'Breakfast';
    if (hour >= 11 && hour < 15) return 'Lunch';
    if (hour >= 15 && hour < 18) return 'Snacks';
    if (hour >= 18 && hour < 22) return 'Dinner';
    return 'Snacks';
  }

  // --- Key/Date Helpers ---
  String _getCacheKey(String userId, DateTime date) {
    // ... (implementation remains the same) ...
    final dateOnly = DateTime(date.year, date.month, date.day);
    return '${userId}_${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
  }

  List<DateTime> _getCurrentWeekDates(DateTime dateInWeek) {
    // ... (implementation remains the same) ...
    final startOfWeek = dateInWeek.subtract(
      Duration(days: dateInWeek.weekday - 1),
    );
    return List.generate(
      7,
      (index) => DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      ),
    );
  }
}
// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for repo injection
// import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
// import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
// import 'package:eat_right/data/services/logic/new_repo/daily_intake_repo.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DailyIntakeController extends GetxController {
//   static DailyIntakeController get instance => Get.find();

//   // Dependencies
//   late final DailyIntakeRepository _repository;
//   final AuthenticationRepository _authRepo = AuthenticationRepository.instance;

//   // UI State
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final Rx<DateTime> _selectedDate = DateTime.now().obs;

//   // Data Cache - Reactive source of truth for loaded data
//   final RxMap<String, DailyIntakeModel> _dailyIntakeCache =
//       RxMap<String, DailyIntakeModel>();

//   // --- Public Reactive Getters for UI ---

//   /// The currently selected date by the user.
//   DateTime get selectedDate => _selectedDate.value;

//   /// Reactive getter for the DailyIntakeModel of the currently selected date.
//   /// Returns null if data is not loaded or doesn't exist.
//   DailyIntakeModel? get currentDailyIntake {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) return null;
//     final cacheKey = _getCacheKey(userId, _selectedDate.value);
//     return _dailyIntakeCache[cacheKey]; // Directly read from reactive cache
//   }

//   /// Reactive getter for the list of DailyIntakeModels for the week containing the selected date.
//   List<DailyIntakeModel> get weeklyIntakeData {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) return [];

//     final weekDates = _getCurrentWeekDates(_selectedDate.value);
//     List<DailyIntakeModel> weekData = [];
//     for (final date in weekDates) {
//       final cacheKey = _getCacheKey(userId, date);
//       if (_dailyIntakeCache.containsKey(cacheKey)) {
//         weekData.add(_dailyIntakeCache[cacheKey]!);
//       } else {
//         // Optionally add an empty model placeholder if desired
//         weekData.add(DailyIntakeModel.empty());
//       }
//     }
//     // Sort by date just in case
//     weekData.sort((a, b) => a.date.compareTo(b.date));
//     return weekData;
//   }

//   // --- Initialization ---

//   @override
//   void onInit() async {
//     super.onInit();
//     // Initialize dependencies (Consider using GetX dependency injection)
//     final prefs = await SharedPreferences.getInstance();
//     _repository = DailyIntakeRepository(FirebaseFirestore.instance, prefs);

//     // Load initial data when user is authenticated
//     ever(
//       _authRepo.onAuthStateChanged,
//       _handleAuthStateChange,
//     ); // React to auth changes
//     _handleAuthStateChange(_authRepo.authUser); // Handle initial state

//     // React to selectedDate changes to load data
//     ever(_selectedDate, (_) => _loadDataForSelectedDate());
//   }

//   void _handleAuthStateChange(dynamic user) {
//     // Parameter type depends on _authRepo stream
//     if (user != null) {
//       print("User authenticated, loading initial data...");
//       _loadDataForSelectedDate(); // Load data for the default selected date
//       _loadDataForWeek(_selectedDate.value); // Load data for the initial week
//     } else {
//       print("User logged out, clearing data...");
//       _clearLocalData();
//     }
//   }

//   void _clearLocalData() {
//     isLoading.value = false;
//     errorMessage.value = '';
//     _dailyIntakeCache.clear();
//     // _selectedDate.value = DateTime.now(); // Reset selected date? Optional.
//   }

//   // --- Public Actions ---

//   /// Changes the selected date and triggers loading data for the new date and week.
//   void selectDate(DateTime newDate) {
//     final normalizedDate = DateTime(newDate.year, newDate.month, newDate.day);
//     if (_selectedDate.value != normalizedDate) {
//       print("Selected date changed to: ${normalizedDate.toIso8601String()}");
//       _selectedDate.value = normalizedDate;
//       // `ever(_selectedDate...)` will trigger loading
//     }
//   }

//   /// Adds a food consumption record.
//   /// Handles updating the correct day's intake and reflects changes reactively.
//   Future<void> addFoodConsumption(FoodConsumptionModel consumption) async {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) {
//       errorMessage.value = 'User not authenticated.';
//       print(errorMessage.value);
//       return;
//     }

//     isLoading.value = true;
//     errorMessage.value = '';

//     try {
//       final consumptionDate = DateTime(
//         consumption.consumedAt.year,
//         consumption.consumedAt.month,
//         consumption.consumedAt.day,
//       );
//       final cacheKey = _getCacheKey(userId, consumptionDate);

//       // 1. Get the intake to update (load if not in cache)
//       DailyIntakeModel intakeToUpdate = await _getOrLoadIntakeForDate(
//         userId,
//         consumptionDate,
//       );

//       // 2. Create the new state by applying changes
//       final newTotalNutrients = _calculateTotalNutrients(
//         intakeToUpdate.totalNutrients,
//         consumption,
//       );
//       final newMealBreakdown = _updateMealTypeBreakdown(
//         intakeToUpdate.mealTypeBreakdown,
//         consumption,
//       );
//       final newFoodIds = [...intakeToUpdate.foodIds, consumption.id];

//       // Ensure ID matches the date key for Firestore consistency
//       final expectedId = _repository.getDateKey(consumptionDate);

//       final updatedIntake = DailyIntakeModel(
//         id: expectedId, // Use the date-based key as ID
//         userId: userId,
//         date: consumptionDate,
//         totalNutrients: newTotalNutrients,
//         foodIds: newFoodIds,
//         mealTypeBreakdown: newMealBreakdown,
//         createdAt: intakeToUpdate.createdAt, // Keep original creation time
//         updatedAt: DateTime.now(), // Update modification time
//       );

//       // 3. Save (Local first, then async remote via Repo)
//       await _repository.saveDailyIntake(updatedIntake);

//       // 4. Update Cache (this triggers reactive updates via getters)
//       _dailyIntakeCache[cacheKey] = updatedIntake;
//       print("Updated cache for $cacheKey after adding consumption.");
//     } catch (e) {
//       errorMessage.value = 'Failed to add food consumption: $e';
//       print('Error adding food consumption: $e');
//       // Consider how to handle the error - maybe rollback is needed if local save failed?
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Manually trigger a refresh of the selected date's data from Firestore.
//   Future<void> refreshCurrentDateData() async {
//     await _fetchAndUpdateCache(_selectedDate.value);
//   }

//   /// Manually trigger a refresh of the current week's data from Firestore.
//   Future<void> refreshWeekData() async {
//     await _loadDataForWeek(_selectedDate.value, forceRemote: true);
//   }

//   // --- Private Loading and Helper Methods ---

//   /// Ensures data for the selected date is loaded (cache or remote).
//   Future<void> _loadDataForSelectedDate() async {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) return; // No user, nothing to load

//     final date = _selectedDate.value;
//     final cacheKey = _getCacheKey(userId, date);

//     if (!_dailyIntakeCache.containsKey(cacheKey)) {
//       print("Data for selected date $date not in cache. Fetching...");
//       await _fetchAndUpdateCache(date);
//     } else {
//       print("Data for selected date $date already in cache.");
//       // Optionally trigger a background refresh anyway
//       // _fetchAndUpdateCache(date);
//     }
//   }

//   /// Fetches data for a specific date from the repository and updates the cache.
//   Future<DailyIntakeModel> _fetchAndUpdateCache(DateTime date) async {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) {
//       return DailyIntakeModel.empty(
//         // userId: '',
//         // date: date,
//       ); // Should not happen if called correctly
//     }
//     isLoading.value = true; // Indicate loading
//     final cacheKey = _getCacheKey(userId, date);

//     // 1. Get local data first
//     DailyIntakeModel? localData = await _repository.getLocalDailyIntake(
//       userId,
//       date,
//     );
//     // Use local data immediately if available, otherwise use empty
//     final initialData = localData ?? DailyIntakeModel.empty();
//     _dailyIntakeCache[cacheKey] = initialData; // Update cache immediately

//     // 2. Fetch remote data in the background
//     try {
//       DailyIntakeModel? remoteData = await _repository.getRemoteDailyIntake(
//         userId,
//         date,
//       );

//       // Update local storage and cache ONLY if remote data is different or newer
//       // (Simple check: if remote exists and local doesn't, or if updatedAt differs)
//       bool shouldUpdate =
//           remoteData != null &&
//           (localData == null ||
//               remoteData.updatedAt.isAfter(localData.updatedAt));

//       if (shouldUpdate) {
//         print(
//           "Remote data fetched for $date is newer/exists. Updating local storage and cache.",
//         );
//         await _repository.saveLocalDailyIntakes(userId, [
//           remoteData,
//         ]); // Save updated data locally
//         _dailyIntakeCache[cacheKey] =
//             remoteData; // Update cache with fresh data
//         localData =
//             remoteData; // Update localData variable for return value consistency
//       } else if (remoteData == null && localData != null) {
//         // Remote doesn't exist but local does. Should we delete local?
//         // Depends on strategy. For now, keep local.
//         print("Remote data doesn't exist for $date, keeping local version.");
//       } else {
//         print(
//           "Remote data fetched for $date is not newer or same as local. No cache update needed from remote.",
//         );
//       }
//     } catch (e) {
//       // Error fetching remote data, log it but rely on local data
//       print("Error fetching remote data for $date: $e");
//       errorMessage.value =
//           "Couldn't sync with cloud for $date."; // Inform user mildly
//     } finally {
//       isLoading.value = false; // Stop loading indicator
//     }
//     // Return the most up-to-date data we have (which might still be the initial local/empty data if remote failed)
//     return _dailyIntakeCache[cacheKey] ?? initialData;
//   }

//   /// Ensures data for a specific date is loaded into the cache, fetching if necessary.
//   /// Returns the DailyIntakeModel for that date.
//   Future<DailyIntakeModel> _getOrLoadIntakeForDate(
//     String userId,
//     DateTime date,
//   ) async {
//     final cacheKey = _getCacheKey(userId, date);
//     if (_dailyIntakeCache.containsKey(cacheKey)) {
//       return _dailyIntakeCache[cacheKey]!;
//     } else {
//       print("Data for target date $date not in cache. Fetching...");
//       // Fetch and update cache, then return
//       return await _fetchAndUpdateCache(date);
//     }
//   }

//   /// Loads data for the entire week containing the given date.
//   Future<void> _loadDataForWeek(
//     DateTime dateInWeek, {
//     bool forceRemote = false,
//   }) async {
//     final userId = _authRepo.authUser?.uid;
//     if (userId == null) return;

//     isLoading.value = true; // Show loading for week load
//     final weekDates = _getCurrentWeekDates(dateInWeek);
//     List<Future> fetchJobs = []; // To run fetches concurrently

//     if (forceRemote) {
//       print("Force refreshing week data from remote...");
//       try {
//         final remoteIntakes = await _repository.getRemoteDailyIntakesForDates(
//           userId,
//           weekDates,
//         );
//         // Save all fetched remote data locally
//         await _repository.saveLocalDailyIntakes(userId, remoteIntakes);
//         // Update cache directly from fetched remote data
//         for (final date in weekDates) {
//           final cacheKey = _getCacheKey(userId, date);
//           // Find matching intake or use empty
//           final matchingIntake = remoteIntakes.firstWhereOrNull(
//             (i) => i.date == date,
//           );
//           _dailyIntakeCache[cacheKey] =
//               matchingIntake ?? DailyIntakeModel.empty();
//         }
//         print("Force remote refresh complete for week of $dateInWeek.");
//       } catch (e) {
//         print("Error during force remote week refresh: $e");
//         errorMessage.value = "Failed to refresh week data from cloud.";
//         // Fallback: ensure local data is loaded if remote fails
//         for (final date in weekDates) {
//           fetchJobs.add(_getOrLoadIntakeForDate(userId, date));
//         }
//         await Future.wait(fetchJobs);
//       }
//     } else {
//       print("Loading week data (cache first) for week of $dateInWeek...");
//       // Load data for each day if not already cached
//       for (final date in weekDates) {
//         final cacheKey = _getCacheKey(userId, date);
//         if (!_dailyIntakeCache.containsKey(cacheKey)) {
//           // Use _getOrLoadIntakeForDate which handles cache check and fetch
//           fetchJobs.add(_getOrLoadIntakeForDate(userId, date));
//         }
//       }
//       if (fetchJobs.isNotEmpty) {
//         await Future.wait(fetchJobs);
//         print("Finished loading missing days for week of $dateInWeek.");
//       } else {
//         print("All data for week of $dateInWeek already in cache.");
//       }
//     }

//     isLoading.value = false;
//   }

//   // --- Calculation Helpers ---

//   Map<String, double> _calculateTotalNutrients(
//     Map<String, double> currentNutrients,
//     FoodConsumptionModel consumption,
//   ) {
//     final Map<String, double> result = Map.from(currentNutrients);
//     result['calories'] = (result['calories'] ?? 0) + consumption.totalCalories;
//     result['protein'] = (result['protein'] ?? 0) + consumption.totalProtein;
//     result['fat'] = (result['fat'] ?? 0) + consumption.totalFat;
//     result['carbohydrates'] =
//         (result['carbohydrates'] ?? 0) + consumption.totalCarbohydrates;
//     result['fiber'] = (result['fiber'] ?? 0) + consumption.totalFiber;

//     // Optionally add other macros if needed for daily totals
//     for (var item in consumption.consumedItems) {
//       item.otherConsumedMacros.forEach((key, quantity) {
//         // Avoid adding things like 'Sodium (mg)' directly if units differ wildly
//         // Stick to core nutrients or well-defined tracked ones for totals map
//         // Example: Only add 'Sugar' if you track total daily sugar
//         // if (key == 'Total Sugars' || key == 'Sugar') {
//         //    result['totalSugar'] = (result['totalSugar'] ?? 0) + quantity.amount.toDouble();
//         // }
//       });
//     }
//     return result;
//   }

//   Map<String, double> _updateMealTypeBreakdown(
//     Map<String, double> currentBreakdown,
//     FoodConsumptionModel consumption,
//   ) {
//     final Map<String, double> result = Map.from(currentBreakdown);
//     final mealType = _inferMealType(consumption.consumedAt);
//     result[mealType] = (result[mealType] ?? 0) + consumption.totalCalories;
//     return result;
//   }

//   String _inferMealType(DateTime consumedAt) {
//     final hour = consumedAt.hour;
//     if (hour >= 4 && hour < 11) return 'Breakfast'; // Wider range
//     if (hour >= 11 && hour < 15) return 'Lunch'; // Wider range
//     if (hour >= 15 && hour < 18) return 'Snacks';
//     if (hour >= 18 && hour < 22) return 'Dinner'; // Wider range
//     return 'Snacks'; // Late night / Early morning
//   }

//   // --- Key/Date Helpers ---

//   String _getCacheKey(String userId, DateTime date) {
//     final dateOnly = DateTime(date.year, date.month, date.day);
//     return '${userId}_${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
//   }

//   List<DateTime> _getCurrentWeekDates(DateTime dateInWeek) {
//     final startOfWeek = dateInWeek.subtract(
//       Duration(days: dateInWeek.weekday - 1),
//     ); // Assuming Monday is 1
//     return List.generate(
//       7,
//       (index) => DateTime(
//         startOfWeek.year,
//         startOfWeek.month,
//         startOfWeek.day + index,
//       ),
//     );
//   }
// }
// // import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
// // import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
// // import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
// // import 'package:eat_right/data/services/logic/new_repo/daily_intake_repo.dart';
// // import 'package:get/get.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class DailyIntakeController extends GetxController {
// //   static DailyIntakeController get instance => Get.find();

// //   late final DailyIntakeRepository _repository;
// //   final Rx<DailyIntakeModel?> currentDailyIntake = Rx<DailyIntakeModel?>(null);
// //   final RxBool isLoading = false.obs;
// //   final RxString errorMessage = ''.obs;
// //   final Rx<DateTime> selectedDate = DateTime.now().obs;
// //   final RxList<DailyIntakeModel> weeklyIntake = <DailyIntakeModel>[].obs;

// //   // Cache for daily intakes
// //   final Map<String, DailyIntakeModel> _dailyIntakeCache = {};

// //   @override
// //   void onInit() async {
// //     super.onInit();
// //     final prefs = await SharedPreferences.getInstance();
// //     _repository = DailyIntakeRepository(prefs);
// //     ever(selectedDate, (_) => loadDailyIntake());
// //   }

// //   // Load daily intake for selected date
// //   Future<void> loadDailyIntake() async {
// //     try {
// //       isLoading.value = true;
// //       errorMessage.value = '';

// //       final userId = AuthenticationRepository.instance.authUser?.uid;
// //       if (userId == null) throw Exception('User not authenticated');

// //       // Check cache first
// //       final cacheKey = _getCacheKey(userId, selectedDate.value);
// //       if (_dailyIntakeCache.containsKey(cacheKey)) {
// //         currentDailyIntake.value = _dailyIntakeCache[cacheKey];
// //         isLoading.value = false;
// //         return;
// //       }

// //       // Load from repository
// //       final intake = await _repository.getDailyIntake(
// //         userId,
// //         selectedDate.value,
// //       );
// //       if (intake != null) {
// //         currentDailyIntake.value = intake;
// //         _dailyIntakeCache[cacheKey] = intake;
// //       }
// //     } catch (e) {
// //       errorMessage.value = 'Failed to load daily intake: $e';
// //       print('Error loading daily intake: $e');
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Add food consumption to daily intake
// //   Future<void> addFoodConsumption(FoodConsumptionModel consumption) async {
// //     try {
// //       isLoading.value = true;
// //       errorMessage.value = '';

// //       final userId = AuthenticationRepository.instance.authUser?.uid;
// //       if (userId == null) throw Exception('User not authenticated');

// //       // Create or update daily intake
// //       final currentData = currentDailyIntake.value;
// //       final newDailyIntake = DailyIntakeModel(
// //         id: currentData?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
// //         userId: userId,
// //         date: consumption.consumedAt,
// //         totalNutrients: _calculateTotalNutrients(
// //           currentData?.totalNutrients ?? {},
// //           consumption.nutrients,
// //         ),
// //         foodIds: [...(currentData?.foodIds ?? []), consumption.id],
// //         mealTypeBreakdown: _updateMealTypeBreakdown(
// //           currentData?.mealTypeBreakdown ?? {},
// //           consumption.,
// //           consumption.nutrients['calories'] ?? 0,
// //         ),
// //         createdAt: currentData?.createdAt ?? DateTime.now(),
// //         updatedAt: DateTime.now(),
// //       );

// //       // Save to repository
// //       await _repository.saveDailyIntake(newDailyIntake);

// //       // Update local state
// //       currentDailyIntake.value = newDailyIntake;
// //       _dailyIntakeCache[_getCacheKey(userId, consumption.consumedAt)] =
// //           newDailyIntake;

// //       // Refresh weekly data if needed
// //       if (_isDateInCurrentWeek(consumption.consumedAt)) {
// //         await loadWeeklyIntake();
// //       }
// //     } catch (e) {
// //       errorMessage.value = 'Failed to add food consumption: $e';
// //       print('Error adding food consumption: $e');
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Load weekly intake data
// //   Future<void> loadWeeklyIntake() async {
// //     try {
// //       isLoading.value = true;
// //       errorMessage.value = '';

// //       final userId = AuthenticationRepository.instance.authUser?.uid;
// //       if (userId == null) throw Exception('User not authenticated');

// //       final startDate = selectedDate.value.subtract(
// //         Duration(days: selectedDate.value.weekday - 1),
// //       );
// //       final weeklyData = await _repository.getWeeklyIntake(userId, startDate);
// //       weeklyIntake.value = weeklyData;
// //     } catch (e) {
// //       errorMessage.value = 'Failed to load weekly intake: $e';
// //       print('Error loading weekly intake: $e');
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   // Helper methods
// //   Map<String, double> _calculateTotalNutrients(
// //     Map<String, double> current,
// //     Map<String, double> newNutrients,
// //   ) {
// //     final Map<String, double> result = Map.from(current);
// //     newNutrients.forEach((key, value) {
// //       result[key] = (result[key] ?? 0) + value;
// //     });
// //     return result;
// //   }

// //   Map<String, double> _updateMealTypeBreakdown(
// //     Map<String, double> current,
// //     String mealType,
// //     double calories,
// //   ) {
// //     final Map<String, double> result = Map.from(current);
// //     result[mealType] = (result[mealType] ?? 0) + calories;
// //     return result;
// //   }

// //   String _getCacheKey(String userId, DateTime date) =>
// //       '${userId}_${date.year}-${date.month}-${date.day}';

// //   bool _isDateInCurrentWeek(DateTime date) {
// //     final now = DateTime.now();
// //     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
// //     final endOfWeek = startOfWeek.add(const Duration(days: 6));
// //     return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
// //   }

// //   // Get nutrient summary for a specific date
// //   Map<String, double> getNutrientSummary(DateTime date) {
// //     final dailyIntake = weeklyIntake.firstWhere(
// //       (intake) =>
// //           intake.date.year == date.year &&
// //           intake.date.month == date.month &&
// //           intake.date.day == date.day,
// //       orElse: () => DailyIntakeModel.empty(),
// //     );
// //     return dailyIntake.totalNutrients;
// //   }

// //   // Get meal type breakdown for a specific date
// //   Map<String, double> getMealTypeBreakdown(DateTime date) {
// //     final dailyIntake = weeklyIntake.firstWhere(
// //       (intake) =>
// //           intake.date.year == date.year &&
// //           intake.date.month == date.month &&
// //           intake.date.day == date.day,
// //       orElse: () => DailyIntakeModel.empty(),
// //     );
// //     return dailyIntake.mealTypeBreakdown;
// //   }
// // }
