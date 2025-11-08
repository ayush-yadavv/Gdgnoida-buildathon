// lib/temp/screens/detailed_day_view_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/food_consumption_model.dart';
import 'package:eat_right/temp/screens/detailed_day_view/detailed_day_view_controller.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailedDayViewPage extends StatelessWidget {
  final DateTime date;

  const DetailedDayViewPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with the specific date, use tag for uniqueness per date
    final controller = Get.put(
      DetailedDayViewController(targetDate: date),
      tag: date.toIso8601String(), // Unique tag based on date
    );

    return Scaffold(
      appBar: SAppBar(
        showBackArrow: true,
        appBarPadding: false,
        removeTitleSpacing: true,
        title: Text(
          "Daily Intakes",
          style: Theme.of(context).textTheme.titleLarge,
        ), // Format date
        actions: [
          Container(
            margin: const EdgeInsets.only(right: Sizes.defaultSpace / 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Text(DateFormat('MMMM d, yyyy').format(date)),
          ),
        ],
        // centerTitle: true,
        // Add refresh action if desired,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: controller.refreshData,
        //     tooltip: "Refresh Data",
        //   )
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData, // Allow pull-to-refresh
        child: Obx(() {
          // Observe controller state
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.defaultSpace),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (controller.consumptionList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.defaultSpace),
                child: Text(
                  "No food items logged for this day.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }

          // Display the list of consumption items
          return ListView.builder(
            padding: const EdgeInsets.all(Sizes.s), // Padding around the list
            itemCount: controller.consumptionList.length,
            itemBuilder: (context, index) {
              final consumptionItem = controller.consumptionList[index];
              return ConsumptionItemTile(
                item: consumptionItem,
              ); // Use a dedicated tile widget
            },
          );
        }),
      ),
    );
  }
}

// --- Dedicated Tile Widget for Displaying FoodConsumptionModel ---
class ConsumptionItemTile extends StatelessWidget {
  final FoodConsumptionModel item;

  const ConsumptionItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String timeString = DateFormat('h:mm a').format(item.consumedAt);
    // Display primary item name or source name
    final primaryName = item.consumedItems.isNotEmpty
        ? item.consumedItems[0].name
        : item.sourceName;
    final otherItemCount = item.consumedItems.length > 1
        ? item.consumedItems.length - 1
        : 0;

    return ListTile(
      // minTileHeight: 44,
      // tileColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(
        // minRadius: ,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: (item.imageUrl != null)
            ? CachedNetworkImage(
                imageUrl: item.imageUrl!,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              )
            : _buildLeadingIcon(item.sourceType), // Icon based on source
      ),
      title: Text(primaryName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          IconBadge(
            icon: Icons.local_fire_department, // Calories (energy/heat)
            label: item.totalCalories.toStringAsFixed(0),
          ),
          IconBadge(
            icon: Icons.fitness_center, // Protein (muscle building)
            label: item.totalProtein.toStringAsFixed(0),
          ),
          IconBadge(
            icon: Icons.water_drop, // Fat (oil/fat representation)
            label: item.totalFat.toStringAsFixed(0),
          ),
          IconBadge(
            icon: Icons.energy_savings_leaf, // Carbs (energy source)
            label: item.totalCarbohydrates.toStringAsFixed(0),
          ),
          IconBadge(
            icon: Icons.grass, // Fiber (plant-based)
            label: item.totalFiber.toStringAsFixed(0),
          ),
        ],
      ),
      titleAlignment: ListTileTitleAlignment.titleHeight,

      trailing: Text(
        "$timeString${otherItemCount > 0 ? " (+ $otherItemCount more items)" : ""}", // Show time and other item count
      ),
      // onTap: () {
      // TODO: Navigate to an even more detailed view of this specific consumption event?
      // Get.snackbar("Info", "Tapped on: ${item.sourceName}");
      // },/
      // TODO: Add potential actions like delete using Slidable or similar
    );
  }

  Widget _buildLeadingIcon(ConsumptionSourceType type) {
    IconData iconData;
    switch (type) {
      case ConsumptionSourceType.meal:
        iconData = Icons.restaurant_menu_rounded;
        break;
      case ConsumptionSourceType.product:
        iconData = Icons.fastfood_rounded;
        break;
      case ConsumptionSourceType.manual:
        iconData = Icons.edit_note_rounded;

        break;
    }
    return Icon(iconData);
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16),
          if (icon != null) SizedBox(width: 2),
          Text(
            // Show total calories for the consumption event
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
