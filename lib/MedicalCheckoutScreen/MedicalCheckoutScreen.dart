import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'MedicalCheckoutDeliveryScreen/MedicalCheckoutDeliveryScreen.dart';

class MedicalCheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final int deliveryCharge;
  final Color primaryColor = const Color(0xFFEB9F3F);

  const MedicalCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCharge
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
            "Medical Checkout",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _checkoutItemCard(cartItems[index]),
            ),
          ),
          _bottomBar(context),
        ],
      ),
    );
  }

  Widget _checkoutItemCard(Map<String, dynamic> item) {
    final double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
    final int qty = item['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['imageUrl'] ?? "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade50,
                child: Icon(Icons.medication_liquid, color: Colors.grey.shade300, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "Medicine",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text("0", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Rs. ${(price * qty).toStringAsFixed(0)}",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Qty. $qty",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    final double totalAmount = subtotal + deliveryCharge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow("Subtotal", "Rs. ${subtotal.toStringAsFixed(0)}", isTotal: false),
            const SizedBox(height: 8),
            _summaryRow("Delivery Charge", "Rs. ${deliveryCharge.toStringAsFixed(0)}", isTotal: false),
            const SizedBox(height: 16),
            _summaryRow("Total Amount", "Rs. ${totalAmount.toStringAsFixed(0)}", isTotal: true, primaryColor: primaryColor),

            const SizedBox(height: 16),

            // Payment Mode Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Very light orange background
                border: Border.all(color: primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.money_outlined, color: primaryColor, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    "Mode of Payment: Cash on Delivery",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confirm/Proceed Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  String? token = GetStorage().read('token');

                  // Mapping data for the API exactly as requested
                  List<Map<String, dynamic>> prepared = cartItems.map((e) => {
                    "id": e['id'] ?? e['_id'] ?? e['itemId'],
                    "quantity": e['quantity'] ?? 1,
                    "type": "Medicine"
                  }).toList();

                  Get.to(() => MedicalCheckoutDeliveryScreen(
                    cartItems: prepared,
                    subtotal: subtotal,
                    deliveryCharge: deliveryCharge,
                    token: token ?? "",
                  ));
                },
                child: const Text(
                  "Proceed to Delivery",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for summary rows
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