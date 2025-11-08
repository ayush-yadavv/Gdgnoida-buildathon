import 'dart:convert';

import 'package:eat_right/data/repositories/Food_repository/food_repository.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodHistoryController extends GetxController {
  static FoodHistoryController get instance => Get.find();
  final foodRepository = Get.put(FoodRepository());
  var foodHistory = <FoodConsumptionModel>[].obs;

  // 4. Food History
  // Functions: loadFoodHistory, addToFoodHistory, _saveFoodHistory

  Future<void> loadFoodHistory() async {
    print("✅Start of loadFoodHistory()");
    print("Loading food history from storage...");
    final prefs = await SharedPreferences.getInstance();
    final String? storedHistory = prefs.getString('food_history');

    if (storedHistory != null) {
      print("Found stored food history");
      try {
        final List<dynamic> decoded = jsonDecode(storedHistory);
        print("Decoded food history items: ${decoded.length}");

        foodHistory.value =
            decoded.map((item) => FoodConsumptionModel.fromJson(item)).toList();

        print("Successfully loaded ${foodHistory.length} food items");
        for (var item in foodHistory) {
          // print("Loaded item: ${item.foodName} on ${item.dateTime}");
        }
        print("✅End of loadFoodHistory()");
      } catch (e) {
        print("Error loading food history: $e");
        foodHistory.value = [];
      }
    } else {
      print("No stored food history found");
      foodHistory.value = [];
    }
  }

  Future<void> addToFoodHistory(FoodConsumptionModel foodItem) async {
    print("✅Start of addToFoodHistory()");
    print("⚡Daily intake at start of addToFoodHistory()");
    print("Adding to food history: $foodItem.foodName");
    print("With nutrients: $foodItem.nutrients");
    print("Source: $foodItem.source");
    print("Image path: $foodItem.imagePath");
    foodHistory.add(foodItem);
    await foodRepository.saveFoodHistory(foodHistory);
  }

  // Future<void> saveFoodHistory() async {
  //   try {
  //     print("✅Start of _saveFoodHistory()");
  //     print("⚡Daily intake at start of _saveFoodHistory()");
  //     final prefs = await SharedPreferences.getInstance();
  //     final historyJson = foodHistory.map((item) => item.toJson()).toList();
  //     print("Saving food history with ${historyJson.length} items");

  //     await prefs.setString('food_history', jsonEncode(historyJson));

  //     // Verify the save
  //     final savedData = prefs.getString('food_history');
  //     final decodedSave =
  //         savedData != null ? jsonDecode(savedData) as List : [];
  //     print("Verification - Saved food history items: ${decodedSave.length}");
  //     print("⚡Daily intake at end of _saveFoodHIistory()");
  //     print("✅End of _saveFoodHistory()");
  //   } catch (e) {
  //     print("Error saving food history: $e");
  //   }
  // }
}
