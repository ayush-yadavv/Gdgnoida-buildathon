import 'package:eat_right/features/main_app/screens/home/home.dart';
import 'package:eat_right/features/personalization/screens/profile_screen/profile_scrn.dart';
import 'package:eat_right/temp/screens/annura_ai_page.dart';
import 'package:eat_right/temp/screens/food_scan_page.dart';
import 'package:eat_right/temp/screens/scan_label_page.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:eat_right/utils/device/device_utility.dart';
import 'package:eat_right/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    // screens to navigate
    const HomeScreen(),
    FoodScanPage(),
    const ScanLabelPage(),
    // const MyHomePage(),
    const AnnuraAiPage(),
    // const AskAiPage(mealName: "rice", foodImage: null),
    // const chatHomeScreen(),
    // const HealthDashboard(),
    ProfileScreen(),
  ];
}

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // dont change below code
    final controller = Get.put(NavigationController());

    // final logicController = Get.put(LogicController());
    final darkMode = SHelperFunctions.isDarkMode(context);
    final navBarBgColor = darkMode ? SColors.black : Colors.white;
    final List<NavigationDestination> destinations = [
      // screen navigation labels
      const NavigationDestination(icon: Icon(Iconsax.home_copy), label: 'Home'),
      const NavigationDestination(icon: Icon(Iconsax.milk_copy), label: 'Food'),
      const NavigationDestination(
        icon: Icon(Iconsax.box_copy),
        label: 'Product',
      ),
      const NavigationDestination(
        icon: Icon(Iconsax.message_2_copy),
        label: 'EarRight AI',
      ),
      const NavigationDestination(
        icon: Icon(Iconsax.health_copy),
        label: 'Health',
      ),
    ];
    return Scaffold(
      bottomNavigationBar: Obx(
        () =>
            // Material(
            //   color: Colors.transparent,
            //   elevation: 10,
            // child:
            Container(
              padding: EdgeInsets.only(top: Sizes.defaultSpace * 0.5),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).bottomNavigationBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),

              child: NavigationBar(
                maintainBottomViewPadding: true,

                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                // labelTextStyle: WidgetStateProperty.all(
                //   Theme.of(context).textTheme.labelSmall!.copyWith(
                //     color: darkMode ? SColors.white : SColors.grey,
                //   ),
                // ),
                height: SDeviceUtils.getBottomNavigationBarHeight(),
                elevation: 4,
                animationDuration: const Duration(milliseconds: 200),
                // indicatorShape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(100),
                // ),
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) {
                  controller.selectedIndex.value = index;
                  HapticFeedback.selectionClick();
                },
                backgroundColor: Colors
                    .transparent, // Make it transparent to match container
                // indicatorColor: darkMode
                //     ? SColors.darkerGrey
                //     : SColors.lightGrey,
                destinations: destinations,
              ),
            ),
      ),
      // ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}
