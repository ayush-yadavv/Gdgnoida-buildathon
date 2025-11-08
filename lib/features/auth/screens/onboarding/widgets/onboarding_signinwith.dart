import 'package:flutter/material.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';

class OnBoardingSn extends StatelessWidget {
  const OnBoardingSn({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: SDeviceUtils.getBottomNavigationBarHeight() + 85,
      left: Sizes.defaultSpace + 4,
      child: Text(
        "Continue with",
        style: Theme.of(context).textTheme.labelMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
