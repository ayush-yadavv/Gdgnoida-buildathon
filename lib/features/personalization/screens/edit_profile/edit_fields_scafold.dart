import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class editProfileFieldsScafold extends StatelessWidget {
  const editProfileFieldsScafold({
    super.key,
    required this.controller,
    required this.appBarTitle,
    required this.description,
    required this.formKey,
    required this.formChild,
    required this.onSaveButtonPressed,
  });

  final GetxController controller;
  final String appBarTitle, description;
  final Key formKey;
  final VoidCallback onSaveButtonPressed;
  final Widget formChild;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar(
        title: Text(
          appBarTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: Sizes.spaceBtwSections),
            Form(key: formKey, child: formChild),
            const SizedBox(height: Sizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(SColors.primary),
                ),
                onPressed: onSaveButtonPressed,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
