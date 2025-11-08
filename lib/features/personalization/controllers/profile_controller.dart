import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_right/data/services/logic/new_data_model/daily_intake_model.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/data/services/logic/new_repo/daily_intake_repo.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final RxMap<DateTime, DailyIntakeModel> dailyIntakes =
      <DateTime, DailyIntakeModel>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  late final DailyIntakeRepository _dailyIntakeRepository;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyIntakeRepository = DailyIntakeRepository(
        FirebaseFirestore.instance,
        prefs,
      );
      await fetchCaloriesData();
    } catch (e) {
      errorMessage.value = 'Error initializing repository: $e';
      isLoading.value = false;
    }
  }

  Future<void> fetchCaloriesData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));

      // Generate list of dates for the last 7 days
      final dates = List.generate(
        7,
        (index) => DateTime(
          sevenDaysAgo.year,
          sevenDaysAgo.month,
          sevenDaysAgo.day + index,
        ),
      );

      // Get intakes for the date range
      final intakes = await _dailyIntakeRepository.getLocalDailyIntakesForDates(
        UserController.instance.user.value.id,
        dates,
      );

      // Create a map of date to intake
      final tempIntakes = <DateTime, DailyIntakeModel>{};

      for (var intake in intakes) {
        final date = DateTime(
          intake.date.year,
          intake.date.month,
          intake.date.day,
        );
        tempIntakes[date] = intake;
      }

      // Fill in missing dates with empty intakes
      for (var date in dates) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (!tempIntakes.containsKey(dateOnly)) {
          tempIntakes[dateOnly] = DailyIntakeModel.empty().copyWith(
            id: _dailyIntakeRepository.getDateKey(dateOnly),
            userId: UserController.instance.user.value.id,
            date: dateOnly,
            totalNutrients: {'calories': 0.0},
          );
        }
      }

      dailyIntakes.value = tempIntakes;
    } catch (e) {
      errorMessage.value = 'Error loading intake data: $e';
      print('Error in fetchCaloriesData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchCaloriesData();
  }
}
