import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AskAiWidgetController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;
  final RxInt currentIndex = 0.obs;

  static const Duration animationDuration = Duration(milliseconds: 1000);
  static const Duration pauseDuration = Duration(milliseconds: 2000);

  final List<String> suggestions = const [
    'What nutrients does this food contain?',
    'Is this food healthy for me?',
    'How many calories in this serving?',
    'What are the health benefits?',
    'Any allergens I should know about?',
  ];

  @override
  void onInit() {
    super.onInit();
    animationController =
        AnimationController(vsync: this, duration: animationDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Future.delayed(pauseDuration, () {
                currentIndex.value =
                    (currentIndex.value + 1) % suggestions.length;
                animationController.reset();
                animationController.forward();
              });
            }
          });

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.5),
          ),
        );

    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class AskAiWidget extends StatelessWidget {
  const AskAiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AskAiWidgetController controller = Get.put(AskAiWidgetController());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => SlideTransition(
                  position: controller.slideAnimation,
                  child: FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: Text(
                      controller.suggestions[controller.currentIndex.value],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
