import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../MapPickerScreen/MapPickerScreen.dart';
import '../OrderController/OrderController.dart';

class MedicalCheckoutDeliveryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final int deliveryCharge;
  final String token;

  MedicalCheckoutDeliveryScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCharge,
    required this.token,
  }) : controller = Get.put(OrderController());

  final OrderController controller;
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Delivery Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Where should we deliver?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Shipping Address
                  _title("Shipping Address"),
                  TextField(
                    controller: controller.addressController,
                    maxLines: 2,
                    decoration: _inputStyle(
                      "Full Address (House No, Street, Area)",
                      Icons.home_work_outlined,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 2. Map Picker Display
                  _title("Pin Your Location"),
                  _buildMapPickerCard(context),
                  const SizedBox(height: 22),

                  // 3. Special Instructions
                  _title("Instructions for Rider"),
                  TextField(
                    controller: controller.instructionController,
                    decoration: _inputStyle(
                      "E.g. Don't ring the bell, call me",
                      Icons.delivery_dining_outlined,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 4. Order Summary Card
                  _summaryCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  // --- UI Components ---

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
      ),
    );
  }

  Widget _buildMapPickerCard(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _coordDisplay("Latitude", controller.latitude.value),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                _coordDisplay("Longitude", controller.longitude.value),
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () async {
              // Hide keyboard before opening map to prevent focus issues
              FocusScope.of(context).unfocus();

              final result = await Get.to(() => MapPickerScreen(
                themeColor: primaryColor,
                initialPosition: controller.latitude.value != null
                    ? LatLng(controller.latitude.value!, controller.longitude.value!)
                    : null,
              ));
              if (result != null && result is LatLng) {
                controller.latitude.value = result.latitude;
                controller.longitude.value = result.longitude;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "SELECT FROM MAP",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _coordDisplay(String label, double? val) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          val?.toStringAsFixed(6) ?? "Not Set",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Payable",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Rs. ${(subtotal + deliveryCharge).toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isPlacingOrder.value
            ? null
            : () async {
          // CRITICAL FIX: Hide keyboard and wait for animation to clear
          // This prevents java.lang.NullPointerException & BLASTBufferQueue crashes
          FocusManager.instance.primaryFocus?.unfocus();
          await Future.delayed(const Duration(milliseconds: 300));

          controller.placeOrder(cartItems: cartItems);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: controller.isPlacingOrder.value
            ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
        )
            : const Text(
          "CONFIRM & PLACE ORDER",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      )),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}