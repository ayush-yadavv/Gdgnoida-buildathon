import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class roundedContainer extends StatelessWidget {
  const roundedContainer({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            SHelperFunctions.isDarkMode(context)
                ? SColors.white.withAlpha(25)
                : SColors.lightGrey,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
