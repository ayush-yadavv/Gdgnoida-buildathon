import 'package:eat_right/data/services/Image_handler/image_controller.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageCaptureButtons extends StatelessWidget {
  const ImageCaptureButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner_outlined, color: Colors.white),
          label: const Text(
            "Scan Now",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => _handleImageCapture(ImageSource.camera),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: Icon(
            Icons.photo_library,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          label: const Text(
            "Gallery",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: SColors.accent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => _handleImageCapture(ImageSource.gallery),
        ),
      ],
    );
  }

  Future<void> _handleImageCapture(ImageSource source) async {
    final ImageController imageController = ImageController();
    await imageController.captureImage(source: source, isFrontImage: true);

    if (Get.context != null) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Get.theme.colorScheme.surface,
          title: Text(
            'Now capture nutrition label',
            style: TextStyle(
              color: Get.theme.colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Please capture or select the nutrition facts label of the product',
            style: TextStyle(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
                await imageController.captureImage(
                  source: source,
                  isFrontImage: false,
                );
                if (imageController.canAnalyze()) {
                  // AnalysisController.instance.analyzeImages(
                  //   frontImage: imageController.frontImage.value!,
                  //   nutritionLabelImage:
                  //       imageController.nutritionLabelImage.value!,
                  // );
                }
              },
              child: const Text(
                'Continue',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}
