import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../ChangePasswordService/ChangePasswordService.dart';


class ChangePasswordController extends GetxController {
  final GetStorage box = GetStorage();
  final ChangePasswordService _service = ChangePasswordService();

  // Text Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Visibility States
  var isCurrentVisible = false.obs;
  var isNewVisible = false.obs;
  var isConfirmVisible = false.obs;

  Future<void> updatePassword() async {
    // Validation
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      EasyLoading.showError("All fields are required");
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      EasyLoading.showError("New passwords do not match");
      return;
    }

    EasyLoading.show(status: "Updating...");

    try {
      String? token = box.read('token');
      if (token == null) {
        EasyLoading.showError("Session expired. Please login again.");
        return;
      }

      final response = await _service.changePasswordApi(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
        token: token,
      );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        // response.data['message'] is "Password changed successfully"
        EasyLoading.showSuccess(response.data['message'] ?? "Success");
        Get.back();
      }
    } on dio.DioException catch (e) {
      EasyLoading.dismiss();
      String msg = e.response?.data['message'] ?? "Failed to change password";
      EasyLoading.showError(msg);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("An unexpected error occurred");
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}