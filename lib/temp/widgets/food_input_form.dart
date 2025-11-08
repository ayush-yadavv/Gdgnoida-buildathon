import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FoodInputFormController extends GetxController {
  // final LogicController logic = Get.find<LogicController>();
  final RxList<TextEditingController> foodItemControllers =
      <TextEditingController>[TextEditingController()].obs;

  void addFoodItem() {
    foodItemControllers.add(TextEditingController());
  }

  void removeFoodItem(int index) {
    foodItemControllers[index].dispose();
    foodItemControllers.removeAt(index);
  }

  void logMeal() {
    final foodItems = foodItemControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .join('\n, ');
    if (foodItems.isNotEmpty) {
      //TODO;
      // MealAnalysisController.instance.analyzeFoodViaText(foodItemsText: foodItems);
      Get.back(); // Close the modal
      // onSubmit();
    }
  }

  @override
  void onClose() {
    for (var controller in foodItemControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}

class FoodInputForm extends StatelessWidget {
  const FoodInputForm({super.key});

  @override
  Widget build(BuildContext context) {
    final FoodInputFormController controller = Get.put(
      FoodInputFormController(),
    );

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   width: 30,
            //   height: 4,
            //   margin: const EdgeInsets.only(bottom: 12),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            //     borderRadius: BorderRadius.circular(3),
            //   ),
            // ),
            Text(
              "Log your meal",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: Sizes.spaceBtwSections),
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.foodItemControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: Sizes.spaceBtwInputFields,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.foodItemControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Food Item ${index + 1}',
                              hintText: 'e.g., Rice 200g or 2 Rotis',
                            ),
                          ),
                        ),
                        if (controller.foodItemControllers.length > 1)
                          IconButton(
                            icon: Icon(Iconsax.minus_copy),
                            onPressed: () {
                              controller.removeFoodItem(index);
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.defaultSpace / 2,
                horizontal: Sizes.defaultSpace / 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).buttonTheme.colorScheme?.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
              ),
              child: GestureDetector(
                onTap: () => controller.addFoodItem(),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.add,
                      // color: Theme.of(
                      //   context,
                      // ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Add another item",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                // controller.logMeal();
              },
              icon: const Icon(Icons.auto_awesome),
              //TODO: add logic
              label: const Text("Analyze(Disabled)"),
            ),
            const SizedBox(height: Sizes.defaultSpace),
          ],
        ),
      ),
    );
  }
}
