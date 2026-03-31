import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../SignOutScreen/SignOutScreen.dart';


class DeliveryDrawer extends StatelessWidget {
  const DeliveryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTheme = Color(0xFFEB9F3F);
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryTheme),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: primaryTheme)),
            accountName: Text("Delivery Partner", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("partner@pcs.com"),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: primaryTheme),
            title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Get.back();
              Get.to(() => const SignOutScreen());
            },
          ),
        ],
      ),
    );
  }
}