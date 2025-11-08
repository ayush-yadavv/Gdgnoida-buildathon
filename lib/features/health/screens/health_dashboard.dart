// import 'package:flutter/material.dart';
// import 'package:flutter_health_connect/flutter_health_connect.dart';
// import 'package:get/get.dart';

// import '../../../data/services/google_health_connect/google_health_connect.dart';

// class HealthDashboard extends StatelessWidget {
//   const HealthDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     bool readOnly = false;
//     String resultText = '';
//     List<HealthConnectDataType> types = [
//       HealthConnectDataType.Steps,
//       HealthConnectDataType.HeartRate,
//       HealthConnectDataType.SleepSession,
//       HealthConnectDataType.OxygenSaturation,
//       HealthConnectDataType.RespiratoryRate,
//     ];
//     final controller = Get.put(GoogleHealthConnectController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Health Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: controller.openHealthConnectSettings,
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // if (!controller.hasPermission.value) {
//         //   return Center(
//         //     child: Column(
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: [
//         //         const Text('Health Connect permissions required'),
//         //         ElevatedButton(
//         //           onPressed: controller.requestPermissions,
//         //           child: const Text('Grant Permissions'),
//         //         ),
//         //       ],
//         //     ),
//         //   );
//         // }

//         return RefreshIndicator(
//           onRefresh: controller.fetchHealthData,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               for (var entry in controller.healthData.entries)
//                 _buildHealthDataCard(entry.key, entry.value.toString()),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () async {
//                   var result = await HealthConnectFactory.isApiSupported();
//                   resultText = 'isApiSupported: $result';
//                   _updateResultText();
//                 },
//                 child: const Text('isApiSupported'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   var result = await HealthConnectFactory.isAvailable();
//                   resultText = 'isAvailable: $result';
//                   _updateResultText();
//                 },
//                 child: const Text('Check installed'),
//               ),

//               ElevatedButton(
//                 onPressed: () async {
//                   await HealthConnectFactory.installHealthConnect();
//                 },
//                 child: const Text('Install Health Connect'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   await HealthConnectFactory.openHealthConnectSettings();
//                 },
//                 child: const Text('Open Health Connect Settings'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   var result = await HealthConnectFactory.hasPermissions(
//                     types,
//                     readOnly: readOnly,
//                   );
//                   resultText = 'hasPermissions: $result';
//                   _updateResultText();
//                 },
//                 child: const Text('Has Permissions'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   var result = await HealthConnectFactory.requestPermissions(
//                     types,
//                     readOnly: readOnly,
//                   );
//                   resultText = 'requestPermissions: $result';
//                   _updateResultText();
//                 },
//                 child: const Text('Request Permissions'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   var startTime = DateTime.now().subtract(
//                     const Duration(days: 4),
//                   );
//                   var endTime = DateTime.now();
//                   var allResults = <String, dynamic>{};

//                   for (var type in types) {
//                     var results = await HealthConnectFactory.getRecord(
//                       type: type,
//                       startTime: startTime,
//                       endTime: endTime,
//                     );
//                     allResults[type.name] = results;
//                   }

//                   resultText = allResults.entries
//                       .map((entry) => '${entry.key}: ${entry.value}')
//                       .join('\n\n');
//                   _updateResultText();
//                 },
//                 child: const Text('Get Record'),
//               ),
//               Text(resultText),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildHealthDataCard(String title, String data) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(data),
//           ],
//         ),
//       ),
//     );
//   }

//   void _updateResultText() {}
// }
