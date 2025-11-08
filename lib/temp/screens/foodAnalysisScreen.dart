// import 'dart:ui';

// import 'package:eat_right/data/services/Image_handler/image_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/analysis_controller.dart';
// import 'package:eat_right/temp/screens/ask_ai_page/ask_ai_page.dart';
// import 'package:eat_right/temp/widgets/ask_ai_widget.dart';
// import 'package:eat_right/temp/widgets/food_item_card.dart';
// import 'package:eat_right/temp/widgets/total_nutrients_card.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../widgets/food_item_card_shimmer.dart';
// import '../widgets/total_nutrients_card_shimmer.dart';

// // class FoodAnalysisController extends GetxController {
// //   final LogicController logic;

// //   FoodAnalysisController(this.logic);
// // }

// class FoodAnalysisScreen extends StatelessWidget {
//   // final LogicController logic;

//   const FoodAnalysisScreen({
//     // required this.logic,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final FoodAnalysisController controller = Get.put(
//     //   FoodAnalysisController(logic),
//     // );

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         flexibleSpace: ClipRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
//             child: Container(color: Colors.transparent),
//           ),
//         ),
//         title: const Text('Food Analysis'),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).padding.bottom + 80,
//           ),

//           // scanning func
//           child: Obx(() {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (AnalysisController.instance.isAnalyzing.value)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           'Analysis Results',
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.onSurface,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                       const FoodItemCardShimmer(),
//                       const FoodItemCardShimmer(),
//                       const TotalNutrientsCardShimmer(),
//                     ],
//                   ),
//                 if (!AnalysisController.instance.isAnalyzing.value &&
//                     AnalysisController.instance.analyzedFoodItems.isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Text(
//                           'Analysis Results',
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.onSurface,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...AnalysisController.instance.analyzedFoodItems.map(
//                         (item) => FoodItemCard(item: item),
//                       ),
//                       TotalNutrientsCard(
//                         // logic: logic
//                       ),

//                       InkWell(
//                         onTap: () {
//                           print("Tap detected!");
//                           Navigator.push(
//                             context,
//                             CupertinoPageRoute(
//                               builder:
//                                   (context) => AskAiPage(
//                                     mealName:
//                                         AnalysisController
//                                             .instance
//                                             .mealName
//                                             .value,
//                                     foodImage:
//                                         ImageController
//                                             .instance
//                                             .frontImage
//                                             .value,
//                                   ),
//                             ),
//                           );
//                         },
//                         child: const AskAiWidget(),
//                       ),
//                     ],
//                   ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
