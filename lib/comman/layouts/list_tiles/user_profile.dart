import 'package:eat_right/comman/shimmer/shimmer.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/edit_profile.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/widgets/circular_img_frame.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/images_str.dart';
import 'package:eat_right/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SUserProfileTile extends StatelessWidget {
  const SUserProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return ListTile(
      // horizontalTitleGap: 0,
      contentPadding: EdgeInsets.zero,
      // tileColor: Theme.of(context).cardColor,
      title: Text(
        controller.user.value.fullName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        controller.user.value.email,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      leading: Obx(() {
        final networkImage = controller.user.value.profileUrl;
        final image = networkImage.isNotEmpty
            ? networkImage
            : SImages.profileImg;
        return (controller.isImageUploading.value)
            ? const BShimmerEffect(width: 60, height: 60)
            : SCircularImage(
                addPadding: true,
                image: image,
                width: 60,
                height: 60,
                isNetworkImage: networkImage.isNotEmpty,
              );
      }),
      trailing: IconButton(
        icon: Icon(
          Iconsax.edit_copy,
          color: SHelperFunctions.isDarkMode(context)
              ? SColors.white
              : SColors.black,
        ),
        onPressed: () => Get.to(const editProfileScreen()),
      ),
    );
  }
}
