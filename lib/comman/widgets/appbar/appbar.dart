import 'package:eat_right/utils/constants/sizes.dart';
import 'package:eat_right/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.appBarPadding = true,
    this.centerTitle = false,
    this.removeTitleSpacing = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final bool appBarPadding;
  final bool centerTitle;
  final bool? removeTitleSpacing;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Iconsax.arrow_left_2_copy),
            )
          : leadingIcon != null
          ? (IconButton(icon: Icon(leadingIcon), onPressed: leadingOnPressed))
          : null,
      title: title,
      titleSpacing: removeTitleSpacing == true ? 0 : Sizes.defaultSpace / 2,
      actions: actions,

      backgroundColor: Colors.transparent,
      // surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
      // iconTheme: Theme.of(context).appBarTheme.iconTheme,
      // titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
    );
  }

  @override
  // dont touch this
  Size get preferredSize => Size.fromHeight(SDeviceUtils.getAppBarHeight());
}
