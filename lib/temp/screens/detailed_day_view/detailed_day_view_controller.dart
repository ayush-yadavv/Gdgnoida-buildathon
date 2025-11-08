// lib/features/main_app/controllers/detailed_day_view_controller.dart

import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/food_consumption_controller.dart';
import 'package:eat_right/data/services/logic/new_repo/food_comsumption_repo.dart';
// import 'package:eat_right/data/services/logic/new_repo/food_consumption_repo.dart';
import 'package:get/get.dart';

class DetailedDayViewController extends GetxController {
  // --- Dependencies ---
  final DailyIntakeController _dailyIntakeController =
      DailyIntakeController.instance;
  final FoodConsumptionRepository _consumptionRepo = FoodConsumptionController
      .instance
      .consumptionRepo; // Use static instance or inject
  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;

  // --- Parameters ---
  final DateTime targetDate;

  // --- State ---
  final RxBool isLoading = true.obs; // Start loading initially
  final RxString errorMessage = ''.obs;
  final Rxn<DailyIntakeModel> dailySummary =
      Rxn<DailyIntakeModel>(); // Hold summary for context
  final RxList<FoodConsumptionModel> consumptionList =
      <FoodConsumptionModel>[].obs;

  // Constructor requires the date
  DetailedDayViewController({required this.targetDate});

  @override
  void onInit() {
    super.onInit();
    print("Initializing DetailedDayViewController for date: $targetDate");
    loadConsumptionDetails();
  }

  // --- Core Logic ---
  Future<void> loadConsumptionDetails({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final userId = _authRepo.currentUser?.uid;

    if (userId == null) {
      errorMessage.value = "User not authenticated.";
      isLoading.value = false;
      return;
    }

    try {
      // 1. Get the DailyIntake Summary (primarily for foodIds)
      // Try cache first, then fetch if needed (forceRefresh bypasses cache)
      DailyIntakeModel? intakeSummary = forceRefresh
          ? null
          : _dailyIntakeController.getDailyIntakeForDate(
              targetDate,
            ); // Use a potential helper in DailyIntakeController

      intakeSummary ??= await _dailyIntakeController.fetchIntakeForDate(
        targetDate,
      );

      dailySummary.value = intakeSummary; // Update summary state

      // 2. Fetch FoodConsumptionModels using the IDs from the summary
      if (intakeSummary.foodIds.isEmpty) {
        print("No food IDs found for $targetDate.");
        consumptionList.clear(); // Clear list if no IDs
      } else {
        print(
          "Fetching ${intakeSummary.foodIds.length} consumption items for $targetDate...",
        );
        final details = await _consumptionRepo.getFoodConsumptionsByIds(
          userId,
          intakeSummary.foodIds,
        );
        consumptionList.assignAll(details); // Update the reactive list
        print("Loaded ${details.length} consumption items.");
      }
    } catch (e) {
      print("Error loading detailed consumption data: $e");
      errorMessage.value = "Failed to load details: $e";
      consumptionList.clear(); // Clear list on error
    } finally {
      isLoading.value = false;
    }
  }

  // --- Actions ---
  Future<void> refreshData() async {
    await loadConsumptionDetails(forceRefresh: true);
  }

  // --- Helpers ---
  // (Add any specific helpers needed for this controller)
}

// Add helper methods to DailyIntakeController if they don't exist:
/*
// In DailyIntakeController class:
DailyIntakeModel? getDailyIntakeForDate(DateTime date) {
   final userId = _authRepo.authUser?.uid;
   if (userId == null) return null;
   final cacheKey = _getCacheKey(userId, date);
   return _dailyIntakeCache[cacheKey];
}

Future<DailyIntakeModel?> fetchIntakeForDate(DateTime date) async {
   // This essentially calls the logic inside _fetchAndUpdateCache
   // It ensures data is loaded from repo if not cached and updates cache
   return await _fetchAndUpdateCache(date);
}
*/
