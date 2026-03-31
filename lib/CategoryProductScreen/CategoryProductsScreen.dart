import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../MedicalSuppliesScreen/MedicalController/MedicalController.dart';
import '../MedicalSuppliesScreen/MedicalDescriptionScreen/MedicalDescriptionScreen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryProductsScreen({super.key, required this.category});
  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final MedicalController controller = Get.find<MedicalController>();
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category['categoryId'] != null) {
        controller.fetchMedicinesByCategory(widget.category['categoryId'].toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Daraz-style light grey background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(widget.category['name'] ?? "Category",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isProductLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (controller.categoryMedicines.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        // Changed from ListView to GridView to match Daraz style
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.categoryMedicines.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,           // 2 items per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,      // Adjusted for vertical card height
          ),
          itemBuilder: (context, index) => darazProductCard(controller.categoryMedicines[index]),
        );
      }),
    );
  }

  /// DARAZ STYLE GRID CARD (Matches MedicalSuppliesScreen)
  Widget darazProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Get.to(() => MedicalDescriptionScreen(
          product: item,
          cartItems: controller.cartItems,
          onCartUpdated: () => controller.cartItems.refresh()
      )),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Top)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Image.network(
                    item['imageUrl'] ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(Icons.medication, color: primaryColor, size: 50),
                  ),
                ),
              ),
            ),
            // Product Details (Bottom)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? "Unknown",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['brandName'] ?? "Brand",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rs. ${item['price'] ?? 0}",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => controller.addToCart(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 0,
                      ),
                      child: const Text(
                          "Add to Cart",
                          style: TextStyle(color: Colors.white, fontSize: 11)
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