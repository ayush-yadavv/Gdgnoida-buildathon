import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageController extends GetxController {
  // static ImageController get instance => Get.find();
  var frontImage = Rx<File?>(null);
  var nutritionLabelImage = Rx<File?>(null);

  // Functions: captureImage, canAnalyze, analyzeImages, analyzeFoodImage

  void clearImages() {
    frontImage.value = null;
    nutritionLabelImage.value = null;
  }

  void clearFrontImage() {
    frontImage.value = null;
  }

  void clearLabelImage() {
    nutritionLabelImage.value = null;
  }

  Future<void> captureImage({
    required ImageSource source,
    required bool isFrontImage,
  }) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);
    if (image != null) {
      if (isFrontImage) {
        frontImage.value = File(image.path);
      } else {
        nutritionLabelImage.value = File(image.path);
      }
    }
  }

  bool canAnalyze() => frontImage.value != null;
}
