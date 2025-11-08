import 'package:eat_right/comman/layouts/list_tiles/settings_menu_tile.dart';
import 'package:eat_right/comman/layouts/list_tiles/user_profile.dart';
import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar(
        removeTitleSpacing: true,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
        child: Column(
          children: [
            const SizedBox(height: Sizes.spaceBtwItems),
            const BSettingMenuTile(
              title: 'Built with',
              icon: Iconsax.lovely,
              subTitle: 'Flutter, Firebase, GetX',
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            // user profile card
            const SUserProfileTile(),
            const SizedBox(height: Sizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => AuthenticationRepository.instance.signOut(),
                child: const Text('Logout'),
              ),
            ),
            // const SizedBox(height: Sizes.spaceBtwSections * 2.5),
          ],
        ),
      ),
    );
  }
}
