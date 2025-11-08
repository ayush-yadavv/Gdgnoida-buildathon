import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class SEditProfileMenu extends StatelessWidget {
  const SEditProfileMenu({
    super.key,
    required this.title,
    required this.value,
    required this.onPressed,
    this.icon,
    this.isScrollableOverflow,
  });

  final String title;
  final String? value;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool? isScrollableOverflow;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceBtwItems / 1.5),
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: dark ? SColors.lightGrey : SColors.darkerGrey,
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwItems / 3),

            ((isScrollableOverflow ?? false)
                ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    // value,
                    // overflow: TextOverflow.ellipsis,
                    value?.replaceAll('\n', ' ') ?? 'Click here to add $title',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
                : Text(
                  value ?? 'Click here to add $title',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                )),

            const SizedBox(height: Sizes.spaceBtwItems / 6),
            Divider(color: dark ? SColors.white : SColors.lightGrey),
          ],
        ),
      ),
    );
  }
}
