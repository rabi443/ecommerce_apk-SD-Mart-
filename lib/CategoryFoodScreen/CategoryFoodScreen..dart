import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FoodScreen/FoodController/FoodController.dart';
import '../FoodScreen/FoodDetailScreen/FoodDetailScreen.dart';

class CategoryFoodScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const CategoryFoodScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  State<CategoryFoodScreen> createState() => _CategoryFoodScreenState();
}

class _CategoryFoodScreenState extends State<CategoryFoodScreen> {
  final FoodController controller = Get.find<FoodController>();
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  void initState() {
    super.initState();
    // Fetch items belonging to this category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchItemsByCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.categoryName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isCategoryItemLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFEB9F3F)));
        }

        if (controller.categoryItems.isEmpty) {
          return const Center(child: Text("No items found in this category."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.categoryItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) => _foodCard(controller.categoryItems[index]),
        );
      }),
    );
  }

  Widget _foodCard(dynamic product) {
    // Robust ID extraction prioritized for 'menuItemId'
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
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: product['imageUrl'] != null && product['imageUrl'] != ""
                      ? Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (c, e, s) => const Icon(Icons.restaurant, size: 40),
                  )
                      : const Icon(Icons.restaurant, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rs. ${product['price']}",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => controller.addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text("Add To Cart",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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