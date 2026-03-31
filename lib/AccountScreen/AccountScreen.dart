import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ProfileScreen/ProfileController/ProfileController.dart';
import '../ProfileScreen/ProfileScreen.dart';
import '../HomeScreen/HomeScreen.dart';
import '../CustomBottomNavBar/CustomBottomNavBar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Get.put ensures the controller is created and found immediately
    final ProfileController controller = Get.put(ProfileController(), permanent: true);
    const Color themeColor = Color(0xFFEB9F3F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAll(() => const HomeScreen()),
        ),
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Obx(() {
              ImageProvider profileImg;
              if (controller.localImage.value != null) {
                profileImg = FileImage(controller.localImage.value!);
              } else if (controller.serverImageUrl.value.isNotEmpty) {
                profileImg = NetworkImage(controller.serverImageUrl.value);
              } else {
                profileImg = const AssetImage("assets/images/profile.png");
              }

              return Column(
                children: [
                  CircleAvatar(
                    // Key forces the widget to refresh when the image data changes
                    key: ValueKey(controller.imageKey.value),
                    radius: 60,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: profileImg,
                  ),
                  const SizedBox(height: 12),
                  Text(controller.displayName.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(controller.displayEmail.value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              );
            }),
            const SizedBox(height: 30),
            sectionTitle("Manage Account", themeColor),
            profileTile(Icons.person_outline, "Edit Information", themeColor, onTap: () => Get.to(() => const ProfileScreen())),
            profileTile(Icons.lock_outline, "Change Password", themeColor, onTap: () {}),
            sectionTitle("App Settings", themeColor),
            profileTile(Icons.notifications_outlined, "Notification", themeColor, onTap: () {}),
            sectionTitle("Privacy and Security", themeColor),
            profileTile(Icons.shield_outlined, "Security", themeColor, onTap: () {}),
            profileTile(Icons.vpn_key_outlined, "Two Factor Authentication", themeColor, onTap: () {}),
            sectionTitle("Legal and Support", themeColor),
            profileTile(Icons.privacy_tip_outlined, "Privacy Policy", themeColor, onTap: () {}),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget sectionTitle(String title, Color themeColor) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor))),
  );

  Widget profileTile(IconData icon, String title, Color themeColor, {required VoidCallback onTap}) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: themeColor, size: 22),
    ),
    title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: onTap,
  );
}