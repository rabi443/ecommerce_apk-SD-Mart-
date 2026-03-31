import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../LoginScreen/LoginScreen.dart';

class SignOutController extends GetxController {
  final GetStorage box = GetStorage();

  Future<void> signOut() async {
    EasyLoading.show(status: "Signing out...");

    // Remove token
    await box.remove('token');



    EasyLoading.dismiss();
    EasyLoading.showSuccess("Signed out successfully");


    Get.offAll(() => const LoginScreen());
  }
}
