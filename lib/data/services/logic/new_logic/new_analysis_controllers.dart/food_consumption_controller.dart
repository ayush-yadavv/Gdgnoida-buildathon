// lib/data/services/logic/new_logic/food_consumption_controller.dart

import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:eat_right/data/services/logic/new_repo/food_comsumption_repo.dart';
import 'package:get/get.dart';

class FoodConsumptionController extends GetxController {
  static FoodConsumptionController get instance => Get.find();

  // Dependencies
  final DailyIntakeController _dailyIntakeController =
      DailyIntakeController.instance;
  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;

  // Initialize repository
  final FoodConsumptionRepository consumptionRepo = FoodConsumptionRepository();

  // State
  final RxBool isLogging = false.obs;
  final RxString loggingError = ''.obs;

  /// Logs a meal consumption event.
  /// Fetches consumptions within a date range
  Future<List<FoodConsumptionModel>> getConsumptionsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _authRepo.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      return await consumptionRepo.getConsumptionsForDateRange(
        startDate,
        endDate,
        userId: userId,
      );
    } catch (e) {
      loggingError.value = 'Failed to fetch consumptions: ${e.toString()}';
      print('Error in getConsumptionsForDateRange: $e');
      rethrow;
    }
  }

  /// Logs a meal consumption event.
  Future<bool> logMealConsumption({
    DateTime? consumedAt,
    required MealAnalysisModel analysis,
  }) async {
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) {
      /* ... handle error ... */
      return false;
    }
    if (analysis.status.toLowerCase() == 'failure') {
      /* ... handle error ... */
      return false;
    }

    _startLogging();
    try {
      // 1. Create the consumption model
      final foodConsumptionModel = FoodConsumptionModel.fromMealAnalysis(
        analysis,
        userId: userId,
        consumedAt: consumedAt,
      );

      // 2. Save the detailed consumption record FIRST
      //    If this fails, we might not want to update the daily summary
      await consumptionRepo.saveFoodConsumption(foodConsumptionModel);
      print("Detailed consumption record saved: ${foodConsumptionModel.id}");

      // 3. Add it to the daily intake summary (if detailed save succeeded)
      await _dailyIntakeController.addFoodConsumption(foodConsumptionModel);

      _completeLogging();
      Get.snackbar(
        'Success',
        '${analysis.mealDetails.nameSuggestion ?? "Meal"} logged successfully!',
      );
      return true;
    } catch (e) {
      _handleLoggingError("Error logging meal: $e");
      return false;
    } finally {
      isLogging.value = false;
    }
  }

  /// Logs a product consumption event.
  Future<bool> logProductConsumption({
    required double servingsConsumed,
    DateTime? consumedAt,
    required ProductAnalysisModel analysis,
  }) async {
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) {
      /* ... handle error ... */
      return false;
    }
    // ... (other validations for servings, analysis status, serving size) ...
    if (analysis.status.toLowerCase() == 'failure') {
      /* ... */
      return false;
    }
    if (servingsConsumed <= 0) {
      /* ... */
      return false;
    }
    if (analysis.nutritionLabel.servingSize?.value == null ||
        analysis.nutritionLabel.servingSize!.value! <= 0) {
      /* ... */
      return false;
    }

    _startLogging();
    try {
      // 1. Create the consumption model
      final foodConsumptionModel = FoodConsumptionModel.fromProductAnalysis(
        analysis,
        userId: userId,
        servingsConsumed: servingsConsumed,
        consumedAt: consumedAt,
      );

      // 2. Save the detailed consumption record FIRST
      await consumptionRepo.saveFoodConsumption(foodConsumptionModel);
      print("Detailed consumption record saved: ${foodConsumptionModel.id}");

      // 3. Add it to the daily intake summary
      await _dailyIntakeController.addFoodConsumption(foodConsumptionModel);

      _completeLogging();
      Get.snackbar(
        'Success',
        '${analysis.productDetails.fullname} logged successfully!',
      );
      return true;
    } catch (e) {
      _handleLoggingError("Error logging product: $e");
      return false;
    } finally {
      isLogging.value = false;
    }
  }

  // --- Private Helpers ---
  void _startLogging() {
    isLogging.value = true;
    loggingError.value = '';
  }

  void _completeLogging() {
    isLogging.value = false;
    loggingError.value = '';
  }

  void _handleLoggingError(String errorMsg) {
    print(errorMsg);
    loggingError.value = errorMsg;
    isLogging.value = false;
    Get.snackbar(
      'Error',
      'Failed to log consumption. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Private Helpers ---
}
