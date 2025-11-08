import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eat_right/utils/loaders/loaders.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    _connectionStatus.value = results.isNotEmpty
        ? results.last
        : ConnectivityResult.none;
    if (_connectionStatus.value == ConnectivityResult.none) {
      // show no internet dialog
      SLoader.customToast(message: 'No Internet Connection');
    }
  }

  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // The list is never empty, and contains ConnectivityResult.none only when there's no connectivity
      return !results.contains(ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
