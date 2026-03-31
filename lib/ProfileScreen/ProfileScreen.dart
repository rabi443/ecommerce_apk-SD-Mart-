import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ProfileController/ProfileController.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Finds the controller created in AccountScreen
    final controller = Get.find<ProfileController>();
    const themeColor = Color(0xFFEB9F3F);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: themeColor, foregroundColor: Colors.white),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: themeColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    ImageProvider img;
                    if (controller.localImage.value != null) {
                      img = FileImage(controller.localImage.value!);
                    } else if (controller.serverImageUrl.value.isNotEmpty) {
                      img = NetworkImage(controller.serverImageUrl.value);
                    } else {
                      img = const AssetImage("assets/images/profile.png");
                    }
                    return CircleAvatar(
                        key: ValueKey(controller.imageKey.value),
                        radius: 70,
                        backgroundImage: img,
                        backgroundColor: Colors.grey.shade200
                    );
                  }),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: themeColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: controller.pickImage,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            _inputField(controller.nameController, "Full Name", Icons.person),
            const SizedBox(height: 20),
            _inputField(controller.emailController, "Email", Icons.email, readOnly: true),
            const SizedBox(height: 20),
            _inputField(controller.phoneController, "Phone", Icons.phone, keyboard: TextInputType.phone),
            const SizedBox(height: 20),
            _inputField(controller.addressController, "Address", Icons.home),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: controller.saveProfile,
                child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFEB9F3F)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
    );
  }
}