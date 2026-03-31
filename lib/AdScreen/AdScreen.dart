import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../HomeScreen/HomeScreen.dart';
import '../core/BaseUrl.dart';
import 'AdController/AdController.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  final AdController controller = Get.put(AdController());
  final PageController _pageController = PageController();

  bool showCloseButton = false;
  Timer? _closeTimer;
  Timer? _autoSlideTimer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _closeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showCloseButton = true);
    });

    // Start auto-slide logic only after data is loaded
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (controller.ads.isNotEmpty) {
        if (currentIndex < controller.ads.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Helper to handle both full URLs and relative paths
  String _getImageUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    // Ensure there is a '/' between base and path
    String baseUrl = BaseUrl.baseurl_api.replaceAll('/api', ''); // Adjust based on your API structure
    return "$baseUrl${path.startsWith('/') ? '' : '/'}$path";
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch $url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(controller.errorMessage.value, textAlign: TextAlign.center),
                  ),
                );
              }

              if (controller.ads.isEmpty) {
                return const Center(child: Text("No ads available"));
              }

              return Column(
                children: [
                  const SizedBox(height: 40),

                  // --- IMAGE CAROUSEL ---
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: controller.ads.length,
                      onPageChanged: (index) {
                        setState(() => currentIndex = index);
                      },
                      itemBuilder: (_, index) {
                        final ad = controller.ads[index];
                        return GestureDetector(
                          onTap: () => _openUrl(ad.redirectUrl),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                _getImageUrl(ad.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --- INDICATORS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.ads.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        width: currentIndex == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index ? const Color(0xFFEB9F3F) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // --- AD DETAILS SECTION ---
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Obx(() {
                        // Safety check for empty list during rebuild
                        if (controller.ads.isEmpty) return const SizedBox();
                        final ad = controller.ads[currentIndex];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Sponsored by ${ad.advertiserName}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  ad.description,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Call to Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => _openUrl(ad.redirectUrl),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEB9F3F),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "Visit Website",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              );
            }),

            // --- CLOSE BUTTON ---
            if (showCloseButton)
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () => Get.offAll(() => const HomeScreen()),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}