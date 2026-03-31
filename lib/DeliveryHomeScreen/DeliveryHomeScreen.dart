import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DeliveryController/DeliveryController.dart';
import 'DeliveryDrawer/DeliveryDrawer.dart';
import 'OrderDetailScreen/OrderDetailScreen.dart';

class DeliveryHomeScreen extends StatelessWidget {
  DeliveryHomeScreen({super.key});

  final DeliveryController controller = Get.put(DeliveryController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryTheme = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DeliveryDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryTheme,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()
        ),
        title: const Text(
            "Home",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchOrders(),
        color: primaryTheme,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// Status Toggle Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: primaryTheme,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                        controller.isOnline.value ? "Status: Online" : "Status: Offline",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    )),
                    Obx(() => Switch(
                        value: controller.isOnline.value,
                        onChanged: (v) => controller.toggleStatus(v),
                        activeColor: Colors.white
                    )),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text("Incoming Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ),
            ),

            /// Dynamic Order List
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Color(0xFFEB9F3F))))
                );
              }
              if (controller.orders.isEmpty) {
                return const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(50), child: Text("No orders found")))
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _orderCard(controller.orders[index]),
                  childCount: controller.orders.length,
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(dynamic order) {
    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailScreen(order: order)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                    backgroundColor: primaryTheme.withOpacity(0.1),
                    child: const Icon(Icons.local_shipping, color: Color(0xFFEB9F3F))
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['orderNumber'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(order['businessName'] ?? "Business", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ]
                    )
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(order['deliveryAddress'] ?? "", style: const TextStyle(fontSize: 13))),
              ],
            ),
            const SizedBox(height: 15),

            /// Functional Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Accurately targeting "orderId" from your API payload
                  String orderId = order['orderId']?.toString() ?? '';
                  if (orderId.isNotEmpty) {
                    controller.completeOrder(orderId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTheme,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                    "Complete",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}