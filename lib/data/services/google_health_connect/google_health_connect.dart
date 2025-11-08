// import 'package:flutter_health_connect/flutter_health_connect.dart';
// import 'package:get/get.dart';

// class GoogleHealthConnectController extends GetxController {
//   static GoogleHealthConnectController get instance => Get.find();
//   final RxBool isLoading = false.obs;
//   final RxMap<String, dynamic> healthData = <String, dynamic>{}.obs;
//   final RxBool hasPermission = false.obs;

//   static final List<HealthConnectDataType> _healthDataTypes = [
//     HealthConnectDataType.ActiveCaloriesBurned,
//     HealthConnectDataType.BasalBodyTemperature,
//     HealthConnectDataType.BasalMetabolicRate,
//     HealthConnectDataType.BloodGlucose,
//     HealthConnectDataType.BloodPressure,
//     HealthConnectDataType.BodyFat,
//     HealthConnectDataType.BodyTemperature,
//     HealthConnectDataType.BoneMass,
//     HealthConnectDataType.CervicalMucus,
//     HealthConnectDataType.CyclingPedalingCadence,
//     HealthConnectDataType.Distance,
//     HealthConnectDataType.ElevationGained,
//     HealthConnectDataType.ExerciseSession,
//     HealthConnectDataType.ExerciseSession,
//     HealthConnectDataType.FloorsClimbed,
//     HealthConnectDataType.HeartRate,
//     HealthConnectDataType.Height,
//     HealthConnectDataType.Hydration,
//     HealthConnectDataType.LeanBodyMass,
//     HealthConnectDataType.MenstruationFlow,
//     HealthConnectDataType.Nutrition,
//     HealthConnectDataType.OvulationTest,
//     HealthConnectDataType.OxygenSaturation,
//     HealthConnectDataType.Power,
//     HealthConnectDataType.RespiratoryRate,
//     HealthConnectDataType.RestingHeartRate,
//     HealthConnectDataType.SexualActivity,
//     HealthConnectDataType.SleepSession,
//     HealthConnectDataType.SleepStage,
//     HealthConnectDataType.Speed,
//     HealthConnectDataType.StepsCadence,
//     HealthConnectDataType.Steps,
//     HealthConnectDataType.TotalCaloriesBurned,
//     HealthConnectDataType.Vo2Max,
//     HealthConnectDataType.Weight,
//     HealthConnectDataType.WheelchairPushes,
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     checkAndInitializeHealthConnect();
//   }

//   Future<void> checkAndInitializeHealthConnect() async {
//     isLoading.value = true;
//     try {
//       final isSupported = await HealthConnectFactory.isApiSupported();
//       print('isSupported: $isSupported');
//       if (!isSupported) {
//         Get.snackbar('Error', 'Health Connect is not supported on this device');
//         return;
//       }

//       final isInstalled = await HealthConnectFactory.isAvailable();
//       print('isInstalled: $isInstalled');
//       if (!isInstalled) {
//         await HealthConnectFactory.installHealthConnect();
//         return;
//       }

//       await checkPermissions();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to initialize Health Connect: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> checkPermissions() async {
//     try {
//       hasPermission.value = await HealthConnectFactory.hasPermissions(
//         _healthDataTypes,
//         // readOnly: true,
//       );

//       if (!hasPermission.value) {
//         await requestPermissions();
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to check permissions: $e');
//     }
//   }

//   Future<void> requestPermissions() async {
//     try {
//       // final isInstalled = await HealthConnectFactory.isAvailable();
//       // if (!isInstalled) {
//       //   await HealthConnectFactory.installHealthConnect();
//       //   return;
//       // }
//       hasPermission.value = await HealthConnectFactory.requestPermissions(
//         _healthDataTypes,
//         readOnly: true,
//       );

//       if (hasPermission.value) {
//         await fetchHealthData();
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to request permissions: $e');
//     }
//   }

//   Future<void> fetchHealthData() async {
//     if (!hasPermission.value) {
//       Get.snackbar('Error', 'Missing required permissions');
//       return;
//     }

//     isLoading.value = true;
//     try {
//       final data = await HealthConnectFactory.getRecord(
//         type: _healthDataTypes[0],
//         startTime: DateTime.now().subtract(const Duration(days: 7)),
//         endTime: DateTime.now(),
//       );
//       healthData[_healthDataTypes[0].toString()] = data;
//       print('Health data: $healthData');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch health data: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void openHealthConnectSettings() async {
//     await HealthConnectFactory.openHealthConnectSettings();
//   }
// }
