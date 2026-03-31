import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../LoginScreen/LoginScreen.dart';
import '../RegisterService/RegisterService.dart';

class RegisterController extends GetxController {
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final referralCode = TextEditingController();
  final otpController = TextEditingController();

  final Color themeColor = const Color(0xFFEB9F3F);

  Future<bool> register() async {
    if (password.text.trim() != confirmPassword.text.trim()) {
      Get.snackbar("Error", "Passwords do not match");
      return false;
    }

    try {
      await RegisterService.registerCustomer(
        username: username.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        password: password.text.trim(),
        referralCode: referralCode.text.trim().isEmpty ? null : referralCode.text.trim(),
      );

      Get.snackbar(
        "OTP Sent",
        "Verification code has been sent to your email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: themeColor,
        colorText: Colors.white,
      );

      _showOtpDialog();
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  void _showOtpDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // This "holds" the screen even if back button is pressed
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Verify Email", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Check your email for the OTP code."),
              const SizedBox(height: 15),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle: TextStyle(color: themeColor),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor)),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: const Text("Verify", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> verifyOtp() async {
    try {
      await RegisterService.verifyEmailOtp(
        email: email.text.trim(),
        otp: otpController.text.trim(),
      );

      Get.back(); // Close dialog

      Get.snackbar(
        "Success",
        "Email verified successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: themeColor,
        colorText: Colors.white,
      );

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar("OTP Error", e.toString());
    }
  }

  @override
  void onClose() {
    username.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    password.dispose();
    confirmPassword.dispose();
    referralCode.dispose();
    otpController.dispose();
    super.onClose();
  }
}