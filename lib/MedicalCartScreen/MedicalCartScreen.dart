import 'package:flutter/material.dart';
import '../MedicalCheckoutScreen/MedicalCheckoutScreen.dart';

class MedicalCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback? onCartUpdated; // Callback to notify parent about cart changes

  const MedicalCartScreen({
    super.key,
    required this.cartItems,
    this.onCartUpdated,
  });

  @override
  State<MedicalCartScreen> createState() => _MedicalCartScreenState();
}

class _MedicalCartScreenState extends State<MedicalCartScreen> {
  // Theme Color
  final Color primaryColor = const Color(0xFFEB9F3F);
  int deliveryCharge = 0;

  @override
  void initState() {
    super.initState();
    for (var item in widget.cartItems) {
      item['quantity'] ??= 1;
    }
  }

  double get subtotal {
    return widget.cartItems.fold(0.0, (sum, item) {
      final double price = (item['price'] is num)
          ? (item['price'] as num).toDouble()
          : double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;

      final int qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  double get total => subtotal + deliveryCharge;

  void increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity']++;
    });
    widget.onCartUpdated?.call(); // Notify parent
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
      }
    });
    widget.onCartUpdated?.call(); // Notify parent
  }

  void removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
    widget.onCartUpdated?.call(); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartItems.isEmpty
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
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];

                final double price = (item['price'] is num)
                    ? (item['price'] as num).toDouble()
                    : double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;

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
                        child: item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty
                            ? Image.network(
                          item['imageUrl'],
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Image.asset("assets/images/medicine.png", height: 70, width: 70);
                          },
                        )
                            : Image.asset("assets/images/medicine.png", height: 70, width: 70),
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
                                      item['name'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => removeItem(index),
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
                                            item['rating']?.toString() ?? '0',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () => decreaseQuantity(index)),
                                    Container(
                                      width: 32,
                                      alignment: Alignment.center,
                                      child: Text(
                                          qty.toString().padLeft(2, '0'),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                                      ),
                                    ),
                                    _qtyBtn(Icons.add, () => increaseQuantity(index)),
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
              },
            ),
          ),

          /// 🔻 BOTTOM SUMMARY
          if (widget.cartItems.isNotEmpty)
            Container(
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
                    _summaryRow("Subtotal", "Rs. ${subtotal.toStringAsFixed(0)}", isTotal: false),
                    const SizedBox(height: 8),
                    _summaryRow("Delivery", "Rs. $deliveryCharge", isTotal: false),
                    const SizedBox(height: 16),
                    _summaryRow("Total", "Rs. ${total.toStringAsFixed(0)}", isTotal: true),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicalCheckoutScreen(
                                cartItems: widget.cartItems,
                                subtotal: subtotal,
                                deliveryCharge: deliveryCharge,
                              ),
                            ),
                          );
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
            )
        ],
      ),
    );
  }

  // Helper widget for quantity buttons
  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
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

  // Helper widget for the summary rows at the bottom
  Widget _summaryRow(String title, String value, {required bool isTotal}) {
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
            color: isTotal ? primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }
}