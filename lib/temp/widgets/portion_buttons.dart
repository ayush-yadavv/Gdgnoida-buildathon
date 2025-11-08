// import 'package:eat_right/data/services/logic/logic.dart';
// import 'package:eat_right/data/services/logic/new_logic/nutrient_controller.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PortionButton extends StatelessWidget {
//   final double portion;
//   final String label;

//   const PortionButton({super.key, required this.portion, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     final NutrientController nutrientController = NutrientController.instance;
//     // final LogicController logic = Get.find<LogicController>();
//     return Obx(() {
//       bool isSelected =
//           (nutrientController.sliderValue.value /
//               nutrientController.servingSize.value) ==
//           portion;
//       return ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor:
//               isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : SColors.borderLight,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         onPressed: () {
//           nutrientController.updateSliderValue(
//             nutrientController.servingSize.value * portion,
//           );
//         },
//         child: Text(
//           label,
//           style: TextStyle(
//             color: Theme.of(context).textTheme.bodyMedium!.color,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       );
//     });
//   }
// }

// class CustomPortionButton extends StatelessWidget {
//   const CustomPortionButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final LogicController logic = Get.find<LogicController>();

//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: SColors.borderLight,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       onPressed: () {
//         showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 title: Text(
//                   'Enter Custom Amount',
//                   style: TextStyle(
//                     color: Theme.of(context).textTheme.bodyMedium!.color,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 content: TextField(
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(
//                     color: Theme.of(context).textTheme.bodyMedium!.color,
//                     fontFamily: 'Poppins',
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'Enter amount in grams',
//                     hintStyle: TextStyle(
//                       color: Theme.of(context).textTheme.bodyMedium!.color,
//                     ),
//                   ),
//                   onChanged: (value) {
//                     NutrientController.instance.updateSliderValue(
//                       double.tryParse(value) ?? 0.0,
//                     );
//                   },
//                 ),
//                 actions: [
//                   TextButton(
//                     child: Text(
//                       'OK',
//                       style: TextStyle(
//                         color: Theme.of(context).textTheme.bodyMedium!.color,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//         );
//       },
//       child: Text(
//         "Custom",
//         style: TextStyle(
//           color: Theme.of(context).textTheme.bodyMedium!.color,
//           fontFamily: 'Poppins',
//         ),
//       ),
//     );
//   }
// }
