import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../HomeScreen/HomeScreen.dart';
import '../PrescriptionService/PrescriptionService.dart';

class PrescriptionController extends GetxController {
  final PrescriptionService _service = PrescriptionService();

  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  // Theme color shared with UI
  final Color primaryColor = const Color(0xFFEB9F3F);

  Future<void> submitPrescription({
    required List<File> images,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? specialInstruction,
  }) async {
    if (isUploading.value) return;

    isUploading.value = true;
    uploadProgress.value = 0;

    // Show Progress Dialog
    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Uploading Prescription...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: uploadProgress.value,
                backgroundColor: Colors.grey.shade200,
                color: primaryColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text("${(uploadProgress.value * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      )),
      barrierDismissible: false,
    );

    final result = await _service.submitPrescription(
      images: images,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      specialInstruction: specialInstruction,
      onProgress: (p) => uploadProgress.value = p,
    );

    Get.back(); // Close progress dialog
    isUploading.value = false;

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      Get.snackbar(
        "Upload Failed",
        result['message'],
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
      );
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon with glow effect
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: primaryColor, size: 60),
              ),
              const SizedBox(height: 24),
              const Text(
                'Submission Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your prescription has been submitted.\nOur team is currently reviewing it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAll(() => const HomeScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Great, Thank You!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}