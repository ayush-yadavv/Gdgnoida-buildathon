import 'package:eat_right/bindings/general_bindings.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/theme/theme_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Eat Right',

      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: GeneralBindings(),
      // show leader meanwhile auth repo is deciding to show screen.
      home: const Scaffold(
        backgroundColor: SColors.primarybg,
        body: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
