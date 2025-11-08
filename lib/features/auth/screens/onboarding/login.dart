import 'package:eat_right/comman/widgets/login_sign_btn/social_buttons.dart';
import 'package:eat_right/features/auth/controllers.login/login_controller.dart';
import 'package:eat_right/features/auth/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:eat_right/features/auth/screens/onboarding/widgets/onboarding_page.dart';
import 'package:eat_right/features/auth/screens/onboarding/widgets/onboarding_signinwith.dart';
import 'package:eat_right/features/auth/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:eat_right/utils/constants/images_str.dart';
import 'package:eat_right/utils/constants/text_str.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(loginController());
    return Scaffold(
      body: Stack(
        children: [
          // Add your logic here
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: SImages.onBoardingImg1,
                title: STexts.onboardingTitle1,
                description: STexts.onboardingDesc1,
              ),
              OnBoardingPage(
                image: SImages.onBoardingImg1,
                title: STexts.onboardingTitle2,
                description: STexts.onboardingDesc2,
              ),
              OnBoardingPage(
                image: SImages.onBoardingImg1,
                title: STexts.onboardingTitle3,
                description: STexts.onboardingDesc3,
              ),
            ],
          ),

          const OnBoardingSkip(),

          const OnBoardingSn(),

          const OnBoardingDotNavigation(),

          const SSocialButtons(),
        ],
      ),
    );
  }
}
