import 'package:eat_right/comman/shimmer/shimmer.dart';
import 'package:eat_right/comman/texts/section_heading.dart';
import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/edit_screens/change_bio.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/edit_screens/change_gender.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/edit_screens/change_name.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/edit_screens/change_username.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/widgets/circular_img_frame.dart';
import 'package:eat_right/features/personalization/screens/edit_profile/widgets/edit_profile_menu_tile.dart';
import 'package:eat_right/utils/constants/images_str.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:eat_right/utils/formatters/formatter.dart';
import 'package:eat_right/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class editProfileScreen extends StatelessWidget {
  const editProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: SAppBar(
        showBackArrow: true,
        appBarPadding: false,
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profileUrl;
                      final image =
                          networkImage.isNotEmpty
                              ? networkImage
                              : SImages.profileImg;
                      return (controller.isImageUploading.value)
                          ? const BShimmerEffect(
                            width: 120,
                            height: 120,
                            borderRadius: 1000,
                          )
                          : SCircularImage(
                            image: image,
                            width: 120,
                            height: 120,
                            isNetworkImage: networkImage.isNotEmpty,
                          );
                    }),
                    TextButton(
                      onPressed: () => controller.updateProfilePicture(),
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              // BSectionHeading(title: 'Public ')
              Obx(() {
                return Column(
                  children: [
                    SEditProfileMenu(
                      title: 'Name',
                      value: controller.user.value.fullName,
                      onPressed: () => Get.to(() => const changeName()),
                    ),
                    SEditProfileMenu(
                      title: 'Username',
                      value: controller.user.value.username,
                      onPressed: () => Get.to(() => const changeUsername()),
                    ),
                    SEditProfileMenu(
                      title: 'Bio',
                      value: controller.user.value.bio,
                      isScrollableOverflow: true,
                      onPressed: () => Get.to(const changeBio()),
                    ),
                  ],
                );
              }),

              const SizedBox(height: Sizes.spaceBtwSections),
              const BSectionHeading(title: "Personal Information"),
              const SizedBox(height: Sizes.spaceBtwItems),
              Obx(() {
                return Column(
                  children: [
                    SEditProfileMenu(
                      title: 'Email ID',
                      value: controller.user.value.email,
                      onPressed: () {
                        SLoader.warningSnackBar(
                          title: 'Warning',
                          message: "You can't change your email id.",
                        );
                      },
                      //  () => Get.to(const changeEmailid())
                    ),
                    SEditProfileMenu(
                      title: 'Gender',
                      value: controller.user.value.gender,
                      onPressed: () => Get.to(const changeGender()),
                    ),
                    SEditProfileMenu(
                      title: 'Phone Number',
                      value:
                          (controller.user.value.phoneNo != null)
                              ? SFormatter.formatPhoneNumber(
                                controller.user.value.phoneNo!,
                              )
                              : null,
                      onPressed: () {},
                    ),
                    SEditProfileMenu(
                      title: 'Date of Birth',
                      value:
                          (controller.user.value.dateOfBirth != null)
                              ? controller.user.value.dateOfBirth!
                                  .toIso8601String()
                              : null,
                      onPressed: () {},
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
