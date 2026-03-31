import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class OrderService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> cartItems,
    required String deliveryAddress,
    required String specialInstructions,
    required double latitude,
    required double longitude,
    Function(double progress)? onProgress,
  }) async {
    final token = GetStorage().read('token');

    try {
      final List<Map<String, dynamic>> itemsPayload = cartItems.map((item) {
        return {
          "ItemId": (item['id'] ?? item['_id'] ?? item['itemId']).toString(),
          "ItemType": item['type'] ?? "Medicine", // Uses item type or defaults to Medicine
          "Quantity": int.tryParse(item['quantity'].toString()) ?? 1
        };
      }).toList();

      final Map<String, dynamic> payload = {
        "Items": itemsPayload,
        "DeliveryAddress": deliveryAddress,
        "Latitude": latitude,
        "Longitude": longitude,
        "SpecialInstructions": specialInstructions,
        "PrescriptionImageUrl": "",
        "CoinsToRedeem": 0
      };

      final response = await _dio.post(
        BaseUrl.customerOrders,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) onProgress(sent / total);
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return success and the Order Number from the response you shared
        return {
          'success': true,
          'orderNumber': response.data['orderNumber'] ?? "N/A"
        };
      }
      return {'success': false, 'message': 'Unexpected status code'};
    } on DioException catch (e) {
      debugPrint("Server Error: ${e.response?.data}");
      return {'success': false, 'message': 'Validation failed on server'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }
}