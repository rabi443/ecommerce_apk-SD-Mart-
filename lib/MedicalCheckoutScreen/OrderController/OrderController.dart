import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../FoodScreen/FoodController/FoodController.dart';
import '../../HomeScreen/HomeScreen.dart';
import '../OrderService/OrderService.dart';

class OrderController extends GetxController {
  final OrderService _service = OrderService();
  final addressController = TextEditingController();
  final instructionController = TextEditingController();

  var latitude = Rxn<double>();
  var longitude = Rxn<double>();
  var isPlacingOrder = false.obs;
  var uploadProgress = 0.0.obs;

  Future<void> placeOrder({required List<Map<String, dynamic>> cartItems}) async {
    if (isPlacingOrder.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 400));

    isPlacingOrder.value = true;
    uploadProgress.value = 0.1;

    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Processing Order", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: uploadProgress.value,
              color: const Color(0xFFEB9F3F),
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      )),
      barrierDismissible: false,
    );

    final result = await _service.placeOrder(
      cartItems: cartItems,
      deliveryAddress: addressController.text.trim(),
      specialInstructions: instructionController.text.trim(),
      latitude: latitude.value!,
      longitude: longitude.value!,
      onProgress: (p) => uploadProgress.value = p,
    );

    // Give Android UI thread time to clear buffers
    await Future.delayed(const Duration(milliseconds: 800));

    if (Get.isDialogOpen ?? false) Get.back();
    isPlacingOrder.value = false;

    if (result['success'] == true) {
      if (Get.isRegistered<FoodController>()) {
        Get.find<FoodController>().clearCart();
      }
      _showSuccessDialog(result['orderNumber']);
    } else {
      Get.snackbar("Error", result['message'], backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void _showSuccessDialog(String orderNum) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFEB9F3F), size: 70),
              const SizedBox(height: 15),
              const Text("Order Successful!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("ID: $orderNum", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 15),
              const Text("Your order has been placed and is being reviewed.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEB9F3F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Get.offAll(() => const HomeScreen()),
                  child: const Text("GREAT!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}