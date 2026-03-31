import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pp/ReferralCodeScreen/ReferralCodeScreen.dart';
import '../ContactUsScreen/ContactUsScreen.dart';
import '../FoodScreen/FoodScreen.dart';
import '../HomeScreen/HomeScreen.dart';
import '../MedicalSuppliesScreen/MedicalSuppliesScreen.dart';
import '../ProfileScreen/ProfileController/ProfileController.dart';
import '../ReferralCodeScreen/ReferralController/ReferralController.dart';
import '../SignOutScreen/SignOutScreen.dart';
import '../VideoScreen/VideoScreen.dart';
import 'UserController/UserController.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});

  final UserController userController = Get.find<UserController>();
  final ReferralController referralController = Get.find<ReferralController>();
  final ProfileController profileController = Get.put(ProfileController());

  // Updated Theme Color
  final Color themeColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // --- MODERN DYNAMIC HEADER ---
          Obx(() {
            ImageProvider profileImage;
            if (profileController.serverImageUrl.value.isNotEmpty) {
              profileImage = NetworkImage(profileController.serverImageUrl.value);
            } else {
              profileImage = const AssetImage("assets/images/user.png");
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 25, right: 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [themeColor, themeColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: profileImage,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userController.name.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userController.role.value == "DeliveryMan" ? "Delivery Expert" : "Verified Customer",
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                  ),
                  if (referralController.referralCode.value.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "PROMO: ${referralController.referralCode.value}",
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            );
          }),

          // --- DRAWER ITEMS ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              children: [
                _buildEyecatchyTile(
                  icon: Icons.grid_view_rounded,
                  title: "Dashboard",
                  onTap: () => Get.offAll(() => const HomeScreen()),
                ),
                _buildEyecatchyTile(
                  icon: Icons.restaurant_rounded,
                  title: "Food Delivery",
                  onTap: () => Get.to(() => VideoScreen()),
                ),
                _buildEyecatchyTile(
                  icon: Icons.medical_services_rounded,
                  title: "Medical Supplier",
                  onTap: () => Get.to(() => MedicalSuppliesScreen()),
                ),
                _buildEyecatchyTile(
                  icon: Icons.card_giftcard_rounded,
                  title: "Redeem Reward",
                  onTap: () => Get.to(() => ReferralCodeScreen()),
                ),
                _buildEyecatchyTile(
                  icon: Icons.headset_mic_rounded,
                  title: "Contact Us",
                  onTap: () => Get.to(() => const ContactUsScreen()),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                ),
                _buildEyecatchyTile(
                  icon: Icons.power_settings_new_rounded,
                  title: "Sign Out",
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  bgColor: Colors.red.withOpacity(0.05),
                  onTap: () => Get.to(() => const SignOutScreen()),
                ),
              ],
            ),
          ),
          // Footer
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "App Version 1.0.2",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // Helper Widget for Eyecatchy Tiles
  Widget _buildEyecatchyTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(icon, color: iconColor ?? themeColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}