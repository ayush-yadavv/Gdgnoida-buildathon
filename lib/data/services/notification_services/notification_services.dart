import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationServices extends GetxController {
  // Notification services
  static NotificationServices get to => Get.find<NotificationServices>();

  // show notification
  void showNotification(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }
}
