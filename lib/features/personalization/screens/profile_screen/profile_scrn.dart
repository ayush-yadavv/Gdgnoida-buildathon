import 'package:eat_right/comman/layouts/profile_card/user_profile_card.dart';
import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/features/personalization/screens/settings_screen/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class profileScreen extends StatelessWidget {
  const profileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar(
        title: const Text("Health DashBoard"),

        actions: [
          IconButton(
            onPressed: () => Get.to(() => UserSettings()),
            icon: const Icon(Iconsax.setting_2_copy),
          ),
          // SizedBox(width: Sizes.defaultSpace / 2),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [userProfileTileMain()]),
      ),
    );
  }
}
