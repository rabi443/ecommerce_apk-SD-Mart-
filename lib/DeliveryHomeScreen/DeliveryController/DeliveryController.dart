import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../core/BaseUrl.dart';

class DeliveryController extends GetxController {
  final GetStorage box = GetStorage();
  final Dio _dio = Dio();

  var isOnline = false.obs;
  var orders = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    String? token = box.read('token');
    if (token == null) return;

    try {
      isLoading(true);
      final response = await _dio.get(
        BaseUrl.deliveryMenOrders,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          // Extract 'result' from each map in the list, ensuring it's not null
          var extracted = (response.data as List)
              .where((e) => e is Map && e.containsKey('result') && e['result'] != null)
              .map((e) => e['result'])
              .toList();

          orders.assignAll(extracted);
        }
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleStatus(bool status) async {
    String? token = box.read('token');
    if (token == null) return;
    EasyLoading.show(status: 'Updating...');
    try {
      await _dio.put(BaseUrl.deliveryMenStatus, data: {"isOnline": status},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      isOnline.value = status;
      EasyLoading.showSuccess("Status Updated");
      fetchOrders();
    } catch (e) {
      EasyLoading.showError("Update Failed");
    }
  }

  // Logic for completing the assigned order
  Future<void> completeOrder(String orderId) async {
    String? token = box.read('token');
    if (token == null) return;

    EasyLoading.show(status: 'Completing order...');
    try {
      // Updated to use your newly added deliverOrder API and empty payload {}
      final response = await _dio.put(
          BaseUrl.deliverOrder(orderId),
          data: {},
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          })
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Displays "Order delivered successfully" from API
        String successMessage = response.data['message'] ?? "Order Completed";
        EasyLoading.showSuccess(successMessage);
        fetchOrders(); // Refresh the incoming orders list
      } else {
        EasyLoading.showError("Failed to complete order");
      }
    } on DioException catch (e) {
      // Catches and shows specific backend errors if any
      EasyLoading.showError("Failed: ${e.response?.data['message'] ?? 'Server Error'}");
    } catch (e) {
      EasyLoading.showError("Failed to complete order");
    }
  }
}