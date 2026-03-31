import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/BaseUrl.dart';
import '../ProfileService/ProfileService.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final isLoading = false.obs;
  final serverImageUrl = "".obs;
  final Rx<File?> localImage = Rx<File?>(null);

  // For UI Sync
  final displayName = "User".obs;
  final displayEmail = "".obs;
  final imageKey = DateTime.now().millisecondsSinceEpoch.obs; // Forces widget refresh

  Map<String, dynamic>? _rawProfileData;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await ProfileService.fetchProfile();
      if (data != null) {
        _rawProfileData = data;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';

        displayName.value = nameController.text;
        displayEmail.value = emailController.text;

        if (data['avatarUrl'] != null && data['avatarUrl'] != "") {
          String path = data['avatarUrl'];
          String domain = BaseUrl.base_url;
          if (domain.endsWith('/')) domain = domain.substring(0, domain.length - 1);
          String cleanPath = path.startsWith('/') ? path : '/$path';

          String finalUrl = "$domain$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}";

          // Clear image from memory
          await NetworkImage(finalUrl).evict();

          serverImageUrl.value = finalUrl;
          imageKey.value = DateTime.now().millisecondsSinceEpoch; // Trigger UI refresh
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      localImage.value = File(image.path);
      imageKey.value = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> saveProfile() async {
    if (_rawProfileData == null) return;
    isLoading.value = true;

    final payload = {
      "customerId": _rawProfileData!['customerId'],
      "userId": _rawProfileData!['userId'],
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "gender": _rawProfileData!['gender'],
      "dateOfBirth": _rawProfileData!['dateOfBirth'],
    };

    if (await ProfileService.updateProfile(payload, localImage.value)) {
      localImage.value = null;
      await loadProfile();
      Get.snackbar("Success", "Profile Updated", backgroundColor: Colors.green, colorText: Colors.white);
    }
    isLoading.value = false;
  }
}