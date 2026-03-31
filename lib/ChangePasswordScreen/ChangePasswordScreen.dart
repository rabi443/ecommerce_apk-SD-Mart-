import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ChangePasswordController/ChangePasswordController.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller into GetX memory
    final ChangePasswordController controller = Get.put(ChangePasswordController());

    // Updated Brand Color
    const Color themeColor = Color(0xFFEB9F3F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            "Change Password",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a strong password to protect your account.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildPasswordField(
              controller: controller.currentPasswordController,
              label: "Current Password",
              themeColor: themeColor,
              visibilityObs: controller.isCurrentVisible,
            ),
            const SizedBox(height: 20),

            _buildPasswordField(
              controller: controller.newPasswordController,
              label: "New Password",
              themeColor: themeColor,
              visibilityObs: controller.isNewVisible,
            ),
            const SizedBox(height: 20),

            _buildPasswordField(
              controller: controller.confirmPasswordController,
              label: "Confirm New Password",
              themeColor: themeColor,
              visibilityObs: controller.isConfirmVisible,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () => controller.updatePassword(),
                child: const Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required Color themeColor,
    required RxBool visibilityObs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller,
          obscureText: !visibilityObs.value,
          cursorColor: themeColor,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: themeColor),
            suffixIcon: IconButton(
              icon: Icon(
                visibilityObs.value ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () => visibilityObs.toggle(),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ],
    );
  }
}