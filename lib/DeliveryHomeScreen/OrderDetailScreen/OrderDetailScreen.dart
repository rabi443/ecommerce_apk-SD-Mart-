import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/BaseUrl.dart'; // Adjust path based on your folder structure
import '../DeliveryController/DeliveryController.dart'; // Adjust path

class OrderDetailScreen extends StatefulWidget {
  final dynamic order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Added state variable to track if the order has been picked up
  bool isPickedUp = false;

  // --- UPDATED LOGIC: Mark order as picked up ---
  Future<void> _markAsPickedUp() async {
    String orderId = widget.order['orderId']?.toString() ?? '';
    if (orderId.isEmpty) {
      EasyLoading.showError("Invalid Order ID");
      return;
    }

    final box = GetStorage();
    String? token = box.read('token');
    if (token == null) {
      EasyLoading.showError("Authentication Error");
      return;
    }

    EasyLoading.show(status: 'Updating status...');
    try {
      final dio = Dio();

      // Using PUT request and passing an empty data object `{}`.
      // Many backends reject PUT requests without a body if Content-Type is json.
      final response = await dio.put(
        BaseUrl.pickupOrder(orderId),
        data: {}, // Added empty data body
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      // Check if the response is successful (200 OK)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // You can also read response.data['message'] here if needed
        EasyLoading.showSuccess("Order Picked Up!");

        // Update UI state to reflect the picked up status
        setState(() {
          isPickedUp = true;
        });

        // Optionally refresh the incoming orders list in the background
        if (Get.isRegistered<DeliveryController>()) {
          Get.find<DeliveryController>().fetchOrders();
        }
      } else {
        EasyLoading.showError("Failed to update status");
      }

    } on DioException catch (e) {
      // Print backend error specifically for debugging
      print("Backend Error: ${e.response?.data}");
      EasyLoading.showError("Failed: ${e.response?.data['message'] ?? 'Server Error'}");
    } catch (e) {
      print("Exception: $e");
      EasyLoading.showError("An unexpected error occurred");
    }
  }

  // --- ADDED LOGIC: Open Google Maps using lat/long ---
  Future<void> _openMap() async {
    var latStr = widget.order['latitude']?.toString();
    var lngStr = widget.order['longitude']?.toString();

    if (latStr == null || lngStr == null) {
      EasyLoading.showError("Location coordinates not available");
      return;
    }

    double? lat = double.tryParse(latStr);
    double? lng = double.tryParse(lngStr);

    if (lat == null || lng == null) {
      EasyLoading.showError("Invalid coordinates");
      return;
    }

    // Google Maps universal URL scheme
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      EasyLoading.showError("Could not open map");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTheme = Color(0xFFEB9F3F);
    List items = widget.order['items'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Order Description", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryTheme,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CUSTOMER INFO", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTheme)),
            _detailRow(Icons.person, "Name", widget.order['customerName']),
            _detailRow(Icons.phone, "Phone", widget.order['customerPhone']),
            _detailRow(Icons.map, "Address", widget.order['deliveryAddress']),
            const SizedBox(height: 30),
            const Text("ITEMS SUMMARY", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTheme)),
            const SizedBox(height: 10),
            ...items.map((item) => Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                title: Text(item['itemName'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Type: ${item['itemType']}", style: const TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: primaryTheme, shape: BoxShape.circle),
                  child: Text(item['quantity'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            )),

            const SizedBox(height: 40),

            // --- UI: Buttons Row ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map, color: Colors.white, size: 20),
                    label: const Text("Show Map", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    // Disable button if it has already been picked up
                    onPressed: isPickedUp ? null : _markAsPickedUp,
                    icon: Icon(
                        isPickedUp ? Icons.check_circle : Icons.local_shipping,
                        color: Colors.white,
                        size: 20
                    ),
                    label: Text(
                        isPickedUp ? "Picked Up" : "Pick Up",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    style: ElevatedButton.styleFrom(
                      // Change color to grey when disabled
                      backgroundColor: isPickedUp ? Colors.grey : primaryTheme,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(val ?? "N/A", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ]
            ),
          )
        ],
      ),
    );
  }
}