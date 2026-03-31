import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../CustomBottomNavBar/CustomBottomNavBar.dart';
import '../HomeScreen/HomeScreen.dart';
import '../core/BaseUrl.dart';
import 'MedicalOrderController/MedicalOrderController.dart';
import 'MedicalOrderDetailScreen/MedicalOrderDetailScreen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final MedicalOrderController controller = Get.put(MedicalOrderController());

  // Updated Brand Colors
  final Color primaryColor = const Color(0xFFEB9F3F);
  final Color lightBg = const Color(0xFFFEF5E7);

  // Toggle State
  String selectedTab = "Food";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
        title: const Text(
            "My Orders",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔘 Custom Tab Buttons (Food & Medicine)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton("Food")),
                Expanded(child: _buildTabButton("Medicine")),
              ],
            ),
          ),

          // 📋 Order List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }

              // Safely filter orders by checking multiple possible API key variations
              final filteredOrders = controller.orderList.where((order) {
                String type = (order['type'] ?? order['Type'] ?? order['orderType'] ?? order['OrderType'] ?? "").toString();

                if (type.isEmpty) {
                  var items = order['items'] ?? order['Items'];
                  if (items != null && items is List && items.isNotEmpty) {
                    var firstItem = items[0];
                    type = (firstItem['itemType'] ?? firstItem['ItemType'] ?? firstItem['type'] ?? firstItem['Type'] ?? "").toString();
                  }
                }
                return type.toLowerCase() == selectedTab.toLowerCase();
              }).toList();

              // Empty State or Error State
              if (filteredOrders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            selectedTab == "Food" ? Icons.fastfood_outlined : Icons.medication_outlined,
                            size: 80,
                            color: Colors.grey.shade300
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.orderList.isEmpty && controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value // Shows exact error
                              : "No $selectedTab orders found.",
                          style: TextStyle(
                              fontSize: 15,
                              color: controller.errorMessage.value.isNotEmpty ? Colors.red.shade400 : Colors.grey
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (controller.orderList.isEmpty)
                          TextButton.icon(
                            onPressed: () => controller.fetchOrders(),
                            icon: Icon(Icons.refresh, color: primaryColor),
                            label: Text("Retry", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () async => controller.fetchOrders(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return orderProductCard(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  // 🎛️ Tab Button Builder
  Widget _buildTabButton(String title) {
    bool isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // 🛍️ Order Card UI
  Widget orderProductCard(Map<String, dynamic> order) {
    // UI logic: Use the first item's image and name to represent the order
    // Using robust extraction to prevent null errors
    final itemsList = (order['items'] ?? order['Items'] ?? []) as List;
    final firstItem = itemsList.isNotEmpty ? itemsList[0] : null;

    final String imageUrl = firstItem != null ? (firstItem['itemImageUrl'] ?? firstItem['ItemImageUrl'] ?? "").toString() : "";
    final String itemName = firstItem != null ? (firstItem['itemName'] ?? firstItem['ItemName'] ?? "$selectedTab Order").toString() : "$selectedTab Order";
    final String totalAmount = (order['totalAmount'] ?? order['TotalAmount'] ?? "0").toString();
    final String orderNum = (order['orderNumber'] ?? order['OrderNumber'] ?? "N/A").toString();
    final String status = (order['customerStatus'] ?? order['CustomerStatus'] ?? "Pending").toString();

    final IconData fallbackIcon = selectedTab == "Food" ? Icons.fastfood : Icons.medication;

    return GestureDetector(
      onTap: () => Get.to(() => MedicalOrderDetailScreen(order: order)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            // 🖼️ Product Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: lightBg,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  "${BaseUrl.base_url}$imageUrl",
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 70,
                      width: 70,
                      color: lightBg,
                      child: Icon(fallbackIcon, color: primaryColor)
                  ),
                )
                    : Container(
                    height: 70,
                    width: 70,
                    color: lightBg,
                    child: Icon(fallbackIcon, color: primaryColor)
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 📝 Middle Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs. $totalAmount",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: $orderNum",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 🏷️ Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}