import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/services/logic/logic.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/text_str.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SHomeAppbar extends StatelessWidget {
  const SHomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LogicController());
    final UserController controller = UserController.instance;
    return SAppBar(
      appBarPadding: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            STexts.homeAppbarTitle,
            style: Theme.of(context).textTheme.labelSmall!.apply(
              color: SColors.white.withOpacity(0.75),
            ),
          ),
          Obx(() {
            if (controller.user.value.fullName.isNotEmpty) {
              return Text(
                controller.user.value.fullName,
                style: Theme.of(context).textTheme.bodyLarge!.apply(
                  color: Colors.white,
                  fontWeightDelta: 1,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Iconsax.notification_bing, color: SColors.white),
      //   ),
      // ],
    );
  }
}
