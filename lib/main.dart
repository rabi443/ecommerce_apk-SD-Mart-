import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


import 'FoodScreen/FoodController/FoodController.dart';
import 'SplashScreen/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for local data
  await GetStorage.init();

  // FIX: Initialize FoodController here so it is available globally.
  // 'permanent: true' prevents it from being deleted when switching screens.
  Get.put(FoodController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce',
      debugShowCheckedModeBanner: false,

      // Keep your existing EasyLoading initialization
      builder: EasyLoading.init(),

      theme: ThemeData(
        // Your primary green color
        primaryColor: const Color(0xFF02754B),
        scaffoldBackgroundColor: Colors.white,
        // UI consistency
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: false,
      ),

      home: const SplashScreen(),
    );
  }
}