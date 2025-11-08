import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/services/logic/logic.dart';
import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/food_consumption_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/meal_analysis_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/produc_analysis_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/utils/network_manager/network_manager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize shared preferences
    Get.put(NetworkManager());
    // Get.put(SharedPreferences, permanent: true);
    // Core repositories and controllers
    Get.put(UserController(), permanent: true);
    Get.put(AuthenticationRepository(), permanent: true);
    Get.put(DailyIntakeController(), permanent: true);
    // Get.put(UserRepository(prefs), permanent: true);
    // Get.put(UserController(), permanent: true);
    Get.put(FoodConsumptionController(), permanent: true);
    Get.put(MealAnalysisController(), permanent: true);
    Get.put(ProductAnalysisController(), permanent: true);
    // Get.put(AskAiController(), permanent: true);

    Get.put(LogicController(), permanent: true);
  }
}
