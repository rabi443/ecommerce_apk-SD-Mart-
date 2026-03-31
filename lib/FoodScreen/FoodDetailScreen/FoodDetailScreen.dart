import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FoodController/FoodController.dart';

class FoodDetailScreen extends StatefulWidget {
  final String productId;
  const FoodDetailScreen({super.key, required this.productId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final FoodController controller = Get.find<FoodController>();
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  void initState() {
    super.initState();
    controller.fetchItemDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Description", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFEB9F3F)));
        }

        var item = controller.selectedProductDetails;
        if (item.isEmpty) return const Center(child: Text("Item not found."));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Center(
                  child: item['imageUrl'] != null
                      ? Image.network(item['imageUrl'], height: 200, fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(Icons.fastfood, size: 100, color: primaryColor))
                      : Icon(Icons.fastfood, size: 100, color: primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              // Thumbnails
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (_, index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(border: Border.all(color: primaryColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                    child: item['imageUrl'] != null ? Image.network(item['imageUrl'], width: 50) : Icon(Icons.image, color: primaryColor, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Name and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item['name'] ?? "Food Item", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  Text("Rs.${item['price']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              // Rating and Availability
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  const Text("4.5", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 15),
                  Text(item['isAvailable'] == true ? "Available" : "Not Available",
                      style: TextStyle(color: item['isAvailable'] == true ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // This correctly displays the description from your API body
              Text(
                item['description'] ?? "No description available for this product.",
                style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 15),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.addToCart(controller.selectedProductDetails),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text("ADD TO CART", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
          ),
        ),
      ),
    );
  }
}