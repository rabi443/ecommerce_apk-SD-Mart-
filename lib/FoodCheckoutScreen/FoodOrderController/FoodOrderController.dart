import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../FoodScreen/FoodController/FoodController.dart'; // Adjust import paths
import '../../HomeScreen/HomeScreen.dart';
import '../FoodOrderService/FoodOrderService.dart';

class FoodOrderController extends GetxController {
  final FoodOrderService _service = FoodOrderService();

  final addressController = TextEditingController();
  final instructionController = TextEditingController();

  var latitude = Rxn<double>();
  var longitude = Rxn<double>();
  var isPlacingOrder = false.obs;
  var uploadProgress = 0.0.obs;

  final Color primaryColor = const Color(0xFFEB9F3F);

  Future<void> submitOrder(List<Map<String, dynamic>> preparedItems) async {
    if (isPlacingOrder.value) return;

    // 1. Unfocus and Wait (Fixes Android Method.invoke / IME crashes)
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    if (addressController.text.trim().isEmpty || latitude.value == null) {
      Get.snackbar(
        "Required",
        "Please provide address and pin your location",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isPlacingOrder.value = true;
    uploadProgress.value = 0.1;

    // 2. Open Progress Dialog
    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Processing Your Order...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: uploadProgress.value,
              backgroundColor: Colors.grey.shade200,
              color: primaryColor,
            ),
          ],
        ),
      )),
      barrierDismissible: false,
    );

    // 3. API Call
    final result = await _service.placeOrder(
      items: preparedItems,
      address: addressController.text.trim(),
      instructions: instructionController.text.trim(),
      latitude: latitude.value!,
      longitude: longitude.value!,
      onProgress: (p) => uploadProgress.value = p,
    );

    // 4. CRITICAL: Timing delay for BLASTBufferQueue error
    await Future.delayed(const Duration(milliseconds: 800));

    if (Get.isDialogOpen ?? false) Get.back();
    isPlacingOrder.value = false;

    if (result['success'] == true) {
      if (Get.isRegistered<FoodController>()) {
        Get.find<FoodController>().clearCart();
      }
      _showSuccess(result['orderNumber']);
    } else {
      Get.snackbar(
        "Order Failed",
        result['message'],
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showSuccess(String orderNum) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 15),
              const Text(
                "Order Successful!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Order ID: $orderNum",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () => Get.offAll(() => const HomeScreen()),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    addressController.dispose();
    instructionController.dispose();
    super.onClose();
  }
}