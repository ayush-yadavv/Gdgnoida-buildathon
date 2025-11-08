import 'package:eat_right/temp/widgets/food_input_form.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AddMealManuallyContainer extends StatelessWidget {
  const AddMealManuallyContainer({
    super.key,
    // required this.logic
  });

  // final LogicController logic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          isScrollControlled: true,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          enableDrag: true,

          SingleChildScrollView(child: FoodInputForm()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.defaultSpace / 2,
          horizontal: Sizes.defaultSpace / 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme?.surfaceContainer,
          borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.add_square),
            const SizedBox(width: 8),
            Text("Add Food Item manually"),
          ],
        ),
      ),
    );
  }
}
