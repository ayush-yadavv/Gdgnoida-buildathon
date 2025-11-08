import 'dart:convert';

import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodRepository extends GetxController {
  static FoodRepository get instance => Get.find();
  // var foodHistory = <FoodConsumption>[].obs;

  Future<void> saveFoodHistory(
    List<FoodConsumptionModel> foodHistoryList,
  ) async {
    try {
      print("✅Start of _saveFoodHistory()");
      print("⚡Daily intake at start of _saveFoodHistory()");
      final prefs = await SharedPreferences.getInstance();
      final historyJson = foodHistoryList.map((item) => item.toJson()).toList();
      print("Saving food history with ${historyJson.length} items");

      await prefs.setString('food_history', jsonEncode(historyJson));

      // Verify the save
      final savedData = prefs.getString('food_history');
      final decodedSave =
          savedData != null ? jsonDecode(savedData) as List : [];
      print("Verification - Saved food history items: ${decodedSave.length}");
      print("⚡Daily intake at end of _saveFoodHIistory()");
      print("✅End of _saveFoodHistory()");
    } catch (e) {
      print("Error saving food history: $e");
    }
  }
}
