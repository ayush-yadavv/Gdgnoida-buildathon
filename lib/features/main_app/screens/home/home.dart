import 'package:eat_right/features/main_app/screens/home/widgets/home_appbar.dart';
import 'package:eat_right/temp/screens/Daily_intake_page.dart'; // Correct import
import 'package:eat_right/temp/widgets/macronutrien_summary_card.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../../comman/containers/primary_header_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the main Scaffold for HomeScreen
      body: Column(
        children: [
          // Fixed Header - Stays at the top
          SPrimaryHeaderContainer(
            bgcolor: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                SHomeAppbar(),
                MacronutrientSummaryCard(
                  // controller.currentDailyIntake?.totalNutrients ?? {},
                ),
                SizedBox(height: Sizes.spaceBtwSections),
                // You could potentially move the HeaderCard/DateSelector here
                // if you want them part of this fixed header instead of scrolling.
              ],
            ),
          ),

          // Scrollable Content Area
          Expanded(
            // Directly place the content of DailyIntakePage here.
            // It already returns a scrollable view (CustomScrollView).
            child: DailyIntakePage(),
            // Removed the SingleChildScrollView and inner Column
          ),
        ],
      ),
    );
  }
}
// import 'package:eat_right/features/main_app/screens/home/widgets/home_appbar.dart';
// import 'package:eat_right/temp/screens/Daily_intake_page.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:eat_right/utils/constants/sizes.dart';
// import 'package:flutter/material.dart';

// import '../../../../comman/containers/primary_header_container.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // Fixed Header
//           SPrimaryHeaderContainer(
//             bgcolor: SColors.primary,
//             child: Column(
//               children: [
//                 SHomeAppbar(),
//                 SizedBox(height: Sizes.spaceBtwSections),
//               ],
//             ),
//           ),

//           // Scrollable Content
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(children: [DailyIntakePage()]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
