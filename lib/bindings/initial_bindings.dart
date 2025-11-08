import 'package:eat_right/utils/network_manager/network_manager.dart';
import 'package:get/get.dart';

import '../../data/repositories/authentication_repo/authentication_repository.dart';
import '../../data/services/logic/new_logic/user_controller.dart';

class InitialBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize shared preferences
    Get.put(NetworkManager());
    // Core repositories and controllers
    Get.put(AuthenticationRepository(), permanent: true);
    // Get.put(UserRepository(prefs), permanent: true);
    Get.put(UserController(), permanent: true);
  }
}
