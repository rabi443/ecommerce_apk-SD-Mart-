import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FoodCheckoutScreen/FoodCheckoutScreen.dart';
import '../FoodScreen/FoodController/FoodController.dart';

class FoodCartScreen extends StatelessWidget {
  const FoodCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Links directly to the globally active FoodController instance
    final FoodController controller = Get.find<FoodController>();
    final Color primaryColor = const Color(0xFFEB9F3F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => Column(
        children: [
          Expanded(
            child: controller.cartItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                      "Your cart is empty",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade400)
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) => _cartItem(index, controller, primaryColor),
            ),
          ),
          if (controller.cartItems.isNotEmpty) _checkoutBottomBar(context, controller, primaryColor),
        ],
      )),
    );
  }

  Widget _cartItem(int index, FoodController controller, Color primaryColor) {
    final item = controller.cartItems[index];
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;
    final int qty = item['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['imageUrl'] ?? "",
              width: 70, height: 70, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                  width: 70, height: 70,
                  color: Colors.grey.shade50,
                  child: Icon(Icons.fastfood, color: Colors.grey.shade300)
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          item['name'] ?? "Food Item",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removeCartItem(index),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Rs. ${price.toStringAsFixed(0)}",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                                "0", // Defaulting rating to 0 based on image
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _qtyBtn(Icons.remove, primaryColor, () => controller.decrementItem(index)),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                              qty.toString().padLeft(2, '0'), // Formats "1" to "01"
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                          ),
                        ),
                        _qtyBtn(Icons.add, primaryColor, () => controller.incrementItem(index)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated to solid orange background with white icon to match the image
  Widget _qtyBtn(IconData icon, Color primaryColor, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(6)
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
  );

  Widget _checkoutBottomBar(BuildContext context, FoodController controller, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow("Subtotal", "Rs. ${controller.subtotal.toStringAsFixed(0)}", isTotal: false),
            const SizedBox(height: 8),
            _summaryRow("Delivery", "Rs. 0", isTotal: false),
            const SizedBox(height: 16),
            _summaryRow("Total", "Rs. ${controller.subtotal.toStringAsFixed(0)}", isTotal: true, primaryColor: primaryColor),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () {
                  // Safety extraction mapping logic for the API
                  List<Map<String, dynamic>> prepared = controller.cartItems.map((e) {
                    dynamic actualId = e['menuItemId'] ?? e['id'] ?? e['_id'] ?? e['itemId'] ?? e['productId'];

                    debugPrint("Mapping Item: ${e['name']} | Extracted ID: $actualId");

                    return {
                      "id": actualId,
                      "quantity": e['quantity'] ?? 1,
                      "name": e['name'],
                      "price": e['price'],
                      "type": "Food"
                    };
                  }).toList();

                  if (prepared.any((item) => item['id'] == null)) {
                    Get.snackbar(
                        "Error",
                        "Invalid Item IDs. Please refresh your menu.",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white
                    );
                    return;
                  }

                  Get.to(() => FoodCheckoutScreen(
                    cartItems: prepared,
                    subtotal: controller.subtotal,
                  ));
                },
                child: const Text(
                    "Proceed to Checkout",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to match the row styling in the bottom bar
  Widget _summaryRow(String title, String value, {required bool isTotal, Color? primaryColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? primaryColor! : Colors.black87,
          ),
        ),
      ],
    );
  }
}