import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_instance;
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class MedicalOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const MedicalOrderDetailScreen({super.key, required this.order});

  // Theme Colors
  final Color primaryColor = const Color(0xFFEB9F3F);
  final Color lightBg = const Color(0xFFFEF5E7);

  /// Helper: Check if within 5-minute window (Handles UTC comparison)
  bool _isWithinCancellationWindow(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return false;
    try {
      DateTime orderTime = DateTime.parse(createdAt).toUtc();
      DateTime now = DateTime.now().toUtc();
      Duration difference = now.difference(orderTime);
      return difference.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  /// Helper to safely combine BaseUrl and Image Path
  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    String baseUrl = BaseUrl.base_url.trim();
    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    String relativePath = path.trim();
    if (relativePath.startsWith('/')) relativePath = relativePath.substring(1);
    return "$baseUrl/$relativePath";
  }

  /// Logic to show Confirmation Dialog
  Future<void> _handleCancelOrder() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Cancel Order",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to cancel this order? This action cannot be undone.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back(); // Close Dialog
              _performCancelRequest();
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// API Request Logic (Changed to POST to solve 405 error)
  Future<void> _performCancelRequest() async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator(color: primaryColor)),
        barrierDismissible: false,
      );

      final box = GetStorage();
      final token = box.read('token');
      final dio = dio_instance.Dio();

      // Identify correct ID (checking multiple keys for safety)
      final String orderId = (order['id'] ?? order['medicalOrderId'] ?? order['orderId'] ?? "").toString();
      final String url = BaseUrl.cancelOrder(orderId);

      // --- CHANGED FROM dio.put TO dio.post ---
      final response = await dio.post(
        url,
        options: dio_instance.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      if (Get.isDialogOpen!) Get.back(); // Hide loading indicator

      String successMsg = "Order cancelled successfully";
      final responseData = response.data;
      if (responseData is Map) {
        successMsg = responseData['message']?.toString() ?? successMsg;
      }

      Get.snackbar(
        "Success",
        successMsg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.back(result: true);
      });
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();

      String errorMsg = "Could not cancel order.";

      if (e is dio_instance.DioException) {
        final responseData = e.response?.data;
        if (responseData != null) {
          if (responseData is Map) {
            errorMsg = responseData['message']?.toString() ?? errorMsg;
          } else {
            errorMsg = responseData.toString();
          }
        } else {
          errorMsg = e.message ?? errorMsg;
        }
      }

      Get.snackbar(
        "Error",
        errorMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPrescriptionImage = order['prescriptionImageUrl'] != null &&
        order['prescriptionImageUrl'].toString().isNotEmpty;
    final bool showPrescriptionSection =
        (order['requiresPrescription'] == true) || hasPrescriptionImage;

    // --- CANCELLATION CONDITIONS (5 Minutes) ---
    final String status = (order['customerStatus'] ?? "").toString().toLowerCase().trim();
    final bool isWithinTime = _isWithinCancellationWindow(order['createdAt']);
    final bool canCancel = status == "pending" && isWithinTime;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (canCancel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SizedBox(
                height: 35,
                child: ElevatedButton(
                  onPressed: _handleCancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: GENERAL INFO ---
            _buildSectionCard(
              title: "General Info",
              icon: Icons.info_outline,
              children: [
                _buildRow("Order #", order['orderNumber'] ?? "N/A"),
                const Divider(height: 24, thickness: 0.5),
                _buildRow("Status", order['customerStatus'] ?? "Pending", isStatus: true),
                const Divider(height: 24, thickness: 0.5),
                _buildRow("Date", order['createdAt']?.toString().split('T')[0] ?? "N/A"),
                const Divider(height: 24, thickness: 0.5),
                _buildRow("Total Amount", "Rs. ${order['totalAmount']}", isHighlight: true),
                if (status == "pending" && !isWithinTime) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "* Cancellation window (5 minutes) has expired.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic),
                  )
                ]
              ],
            ),
            const SizedBox(height: 16),

            // --- SECTION 2: DELIVERY & INFO ---
            _buildSectionCard(
              title: "Delivery & Info",
              icon: Icons.local_shipping_outlined,
              children: [
                _buildDeliveryRow(Icons.location_on, "Address", order['deliveryAddress'] ?? "Not Provided"),
                if (order['orderDescription'] != null && order['orderDescription'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDeliveryRow(Icons.description_outlined, "Order Description", order['orderDescription']),
                ],
                const SizedBox(height: 16),
                _buildDeliveryRow(Icons.note_alt_outlined, "Special Instructions", order['specialInstructions'] ?? "None"),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECTION 3: ITEMS ---
            _buildSectionCard(
              title: "Items Purchased (${(order['items'] as List?)?.length ?? 0})",
              icon: Icons.shopping_bag_outlined,
              children: (order['items'] as List? ?? []).map<Widget>((item) {
                return _buildItemCard(item);
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- SECTION 4: PRESCRIPTION ---
            if (showPrescriptionSection) ...[
              _buildSectionCard(
                title: "Attached Prescription",
                icon: Icons.description_outlined,
                children: [
                  _buildPrescriptionImage(order['prescriptionImageUrl']),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false, bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.5)),
            ),
            child: Text(value.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11)),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              fontSize: isHighlight ? 16 : 14,
              color: isHighlight ? primaryColor : Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: lightBg, shape: BoxShape.circle),
          child: Icon(icon, color: primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final imageUrl = _getImageUrl(item['itemImageUrl']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 55,
              width: 55,
              color: lightBg,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.medication_liquid, color: primaryColor, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['itemName'] ?? "Unknown Item", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("Quantity: ${item['quantity']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("Rs. ${item['unitPrice']}", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionImage(String? path) {
    final fullUrl = _getImageUrl(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
        child: path == null || path.isEmpty
            ? _buildNoImagePlaceholder("No prescription image attached")
            : Image.network(fullUrl, width: double.infinity, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => _buildNoImagePlaceholder("Failed to load image")),
      ),
    );
  }

  Widget _buildNoImagePlaceholder(String text) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      color: lightBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, color: primaryColor, size: 40),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}