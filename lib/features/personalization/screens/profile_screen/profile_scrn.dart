import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/features/personalization/controllers/profile_controller.dart';
import 'package:eat_right/features/personalization/screens/settings_screen/user_settings.dart';
import 'package:eat_right/features/personalization/widgets/calories_chart.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      appBar: SAppBar(
        title: const Text("Health DashBoard"),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const UserSettings()),
            icon: const Icon(Iconsax.setting_2_copy),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (controller.dailyIntakes.isEmpty) {
          return Center(
            child: Text(
              'No calorie data available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshData();
          },
          child: Column(
            children: [
              // userProfileTileMain(),
              // const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.defaultSpace,
                    vertical: Sizes.spaceBtwItems,
                  ),
                  child: CaloriesChart(dailyIntakes: controller.dailyIntakes),
                );
              }),
              // const SizedBox(height: Sizes.spaceBtwItems),
              TextButton.icon(
                onPressed: () => controller.refreshData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
            ],
          ),
        );
      }),
    );
  }
}
