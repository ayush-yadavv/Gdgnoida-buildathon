import 'package:eat_right/comman/layouts/profile_card/user_profile_card.dart';
import 'package:flutter/material.dart';

class profileScreen extends StatelessWidget {
  const profileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [userProfileTileMain()]),
      ),
    );
  }
}
