import 'package:flutter/material.dart';

class MedicalDescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCartUpdated;

  const MedicalDescriptionScreen({
    super.key,
    required this.product,
    required this.cartItems,
    required this.onCartUpdated,
  });

  final Color primaryColor = const Color(0xFFEB9F3F);

  void _addToCart(BuildContext context) {
    final productId = product['medicineId'] ?? product['id'] ?? product['categoryId'];

    final index = cartItems.indexWhere((item) =>
    (item['id'] ?? item['medicineId']) == productId);

    if (index != -1) {
      cartItems[index]['quantity']++;
    } else {
      cartItems.add({
        ...product,
        "id": productId,
        "quantity": 1,
      });
    }

    onCartUpdated();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['name']} added to cart"),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Description", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Center(
                child: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                    ? Image.network(product['imageUrl'], height: 200, fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.medication, size: 100, color: primaryColor))
                    : Icon(Icons.medication, size: 100, color: primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, index) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: primaryColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                  child: product['imageUrl'] != null ? Image.network(product['imageUrl'], width: 50) : Icon(Icons.image, color: primaryColor, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(product['name'] ?? "Product Name", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                Text("Rs.${product['price']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text((product['rating'] ?? "4.0").toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              product['description'] ?? "No description available for this product.",
              style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 15),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _addToCart(context),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text("ADD TO CART", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
          ),
        ),
      ),
    );
  }
}