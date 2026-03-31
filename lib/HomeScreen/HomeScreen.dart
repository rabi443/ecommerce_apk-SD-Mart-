import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pp/ReferralCodeScreen/ReferralCodeScreen.dart';

import '../CustomBottomNavBar/CustomBottomNavBar.dart';
import '../DrawerScreen/DrawerScreen.dart';
import '../FoodScreen/FoodScreen.dart';
import '../MedicalSuppliesScreen/MedicalSuppliesScreen.dart';
import '../VideoScreen/VideoScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final Color primaryColor = const Color(0xFFEB9F3F); // Updated theme color

  final List<String> bannerImages = [
    'assets/images/carousel1.png',
    'assets/images/carousel2.png',
  ];

  final List<Map<String, String>> partners = [
    {'image': 'assets/images/laziz.png', 'name': 'Laziz Pizza'},
    {'image': 'assets/images/singhasan.png', 'name': 'Singhasan'},
    {'image': 'assets/images/bajeko.png', 'name': 'Bajeko Sekuwa'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: primaryColor, // Updated
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        elevation: 0,
        toolbarHeight: 45,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReferralCodeScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/coin.png', height: 19, width: 19),
                  const SizedBox(width: 5),
                  const Text(
                    "Reward",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryColor, // Updated
            padding: const EdgeInsets.only(bottom: 20),
            child: const SizedBox(height: 0),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.03),

                    // CAROUSEL
                    SizedBox(
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: screenWidth * 0.5,
                          autoPlay: true,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          onPageChanged: (index, _) {
                            setState(() => _currentIndex = index);
                          },
                        ),
                        items: bannerImages.map((path) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              path,
                              width: double.infinity,
                              height: screenWidth * 0.50,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: bannerImages.asMap().entries.map((entry) {
                        return Container(
                          width: screenWidth * 0.02,
                          height: screenWidth * 0.02,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key
                                ? primaryColor // Updated
                                : Colors.grey[400],
                          ),
                        );
                      }).toList(),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "What are you looking for?",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            imagePath: 'assets/images/medical_icon.png',
                            title: 'Medical Supplier',
                            subtitle: 'Order medical supplies',
                            color: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MedicalSuppliesScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: _buildCategoryCard(
                            imagePath: 'assets/images/food_icon.png',
                            title: 'Food Delivery',
                            subtitle: 'Order food delivery',
                            color: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FoodScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text("Our New Partners", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: partners.map((partner) {
                        return Expanded(
                          child: Container(
                            height: screenWidth * 0.25,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(partner['image']!, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 40, width: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}