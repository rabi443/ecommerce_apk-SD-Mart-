import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../CategoryFoodScreen/CategoryFoodScreen..dart';
import '../FoodCartScreen/FoodCartScreen.dart';
import 'FoodController/FoodController.dart';
import 'FoodDetailScreen/FoodDetailScreen.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final FoodController controller = Get.put(FoodController());
  final TextEditingController _searchController = TextEditingController();
  final RxString _query = "".obs;

  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Food Menu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          Obx(() => IconButton(
            icon: Badge(
              label: Text(
                controller.cartItems.length.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
            ),
            // FIXED: Removed cartItems argument because FoodCartScreen connects directly to GetX
            onPressed: () => Get.to(() => const FoodCartScreen()),
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 Search Bar Section
            Container(
              color: primaryColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => _query.value = val,
                decoration: InputDecoration(
                  hintText: "Search chicken burger, pizza...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🖼️ Promotional Banner
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                        ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/food.png",
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, color: primaryColor.withOpacity(0.5), size: 50),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),

                  /// 📂 Horizontal Dynamic Categories
                  SizedBox(
                    height: 95,
                    child: Obx(() {
                      if (controller.isCategoryLoading.value) {
                        return Center(child: CircularProgressIndicator(color: primaryColor));
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.foodCategories.length,
                        itemBuilder: (context, index) {
                          var cat = controller.foodCategories[index];
                          String catId = (cat['menuCategoryId'] ?? cat['id'] ?? cat['_id'] ?? "").toString();

                          return _categoryItem(
                              cat['name'] ?? "",
                              Icons.fastfood,
                                  () => Get.to(() => CategoryFoodScreen(
                                  categoryId: catId,
                                  categoryName: cat['name'] ?? "Category"
                              ))
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  const Text("Just For You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),

                  /// 🍱 Food Product Grid
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: primaryColor),
                      ));
                    }

                    var filteredList = controller.allMenuItems.where((p) =>
                        p['name'].toString().toLowerCase().contains(_query.value.toLowerCase())).toList();

                    if (filteredList.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No items found.", style: TextStyle(color: Colors.grey)),
                      ));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) => _foodCard(filteredList[index]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        width: 85,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, spreadRadius: 0, offset: const Offset(0, 2))
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const Spacer(),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodCard(dynamic product) {
    final String itemId = (product['menuItemId'] ?? product['id'] ?? product['_id'] ?? "").toString();

    return GestureDetector(
      onTap: () {
        if (itemId.isNotEmpty) {
          Get.to(() => FoodDetailScreen(productId: itemId));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  child: product['imageUrl'] != null && product['imageUrl'] != ""
                      ? Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (c, e, s) => Icon(Icons.restaurant, color: primaryColor.withOpacity(0.5), size: 40),
                  )
                      : Icon(Icons.restaurant, color: primaryColor.withOpacity(0.5), size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product['category']?['name'] ?? "Food",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rs. ${product['price']}",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 36, // Improved touch area
                    child: ElevatedButton(
                      onPressed: () => controller.addToCart(product),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text(
                          "Add To Cart",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.3)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}