import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;

import '../../AdScreen/AdScreen.dart';
import '../../DeliveryHomeScreen/DeliveryHomeScreen.dart';
import '../../DrawerScreen/UserController/UserController.dart';
import '../../ReferralCodeScreen/ReferralController/ReferralController.dart';
import '../service/LoginService.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage();
  final UserController userController = Get.put(UserController(), permanent: true);
  final ReferralController referralController = Get.put(ReferralController(), permanent: true);

  @override
  void onInit() {
    super.onInit();
    // Auto-login check when controller initializes
    checkAutoLogin();
  }

  void checkAutoLogin() {
    String? token = box.read('token');
    if (token != null) {
      String? role = box.read('role');
      String? name = box.read('name');

      // Restore global user state
      userController.setUser(name: name ?? "User", role: role ?? "Customer");

      // Redirect based on role
      if (role == "DeliveryMan") {
        Future.delayed(Duration.zero, () => Get.offAll(() => DeliveryHomeScreen()));
      } else {
        Future.delayed(Duration.zero, () => Get.offAll(() => const AdScreen()));
      }
    }
  }

  Future<void> loginUser({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      EasyLoading.showError("Please fill all fields");
      return;
    }

    EasyLoading.show(status: "Logging in...");

    try {
      final response = await LoginService.login(email, password);

      if (response['token'] != null) {
        // --- Store Tokens ---
        box.write('token', response['token']);
        box.write('refreshToken', response['refreshToken']); // Store refresh token

        var userData = response['user'];
        String name = userData?['name'] ?? "User";
        String role = userData?['role'] ?? "Customer";

        // Persistence for auto-login
        box.write('role', role);
        box.write('name', name);

        // 1️⃣ Update Global State
        userController.setUser(name: name, role: role);

        // 2️⃣ Navigation Logic
        if (role == "DeliveryMan") {
          EasyLoading.dismiss();
          EasyLoading.showSuccess("Login Successful");
          Get.offAll(() => DeliveryHomeScreen());
        } else {
          try {
            await referralController.loadReferralInfo();
            EasyLoading.dismiss();
            EasyLoading.showSuccess("Login Successful");
            Get.offAll(() => const AdScreen());
          } catch (e) {
            EasyLoading.dismiss();
            Get.offAll(() => const AdScreen());
          }
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      String errorMessage = "Invalid email or password";

      if (e is dio.DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.type == dio.DioExceptionType.connectionTimeout) {
          errorMessage = "Connection Timed Out";
        }
      }

      EasyLoading.showError(errorMessage);
    }
  }
}