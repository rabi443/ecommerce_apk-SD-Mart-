import 'package:get/get.dart';

import '../MedicalOrderService/MedicalOrderService.dart';

class MedicalOrderController extends GetxController {
  var isLoading = true.obs;
  var orderList = [].obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  void fetchOrders() async {
    try {
      isLoading(true);
      errorMessage.value = ""; // Clear old errors
      var orders = await MedicalOrderService().fetchCustomerOrders();
      orderList.assignAll(orders);
    } catch (e) {
      // Replaced generic message with the EXACT error to help debugging
      errorMessage.value = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading(false);
    }
  }
}