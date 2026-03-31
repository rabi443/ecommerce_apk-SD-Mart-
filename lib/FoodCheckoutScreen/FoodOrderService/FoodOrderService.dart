import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class FoodOrderService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required String address,
    required String instructions,
    required double latitude,
    required double longitude,
    Function(double progress)? onProgress,
  }) async {
    final String? token = GetStorage().read('token');

    try {
      final List<Map<String, dynamic>> itemsPayload = items.map((e) {
        // Extract ID and trim it to ensure no whitespace issues
        String rawId = (e['id'] ?? e['_id'] ?? e['itemId'] ?? "").toString().trim();

        // If ID is empty, the .NET Guid conversion WILL fail
        if (rawId.isEmpty) {
          debugPrint("CRITICAL: Sending an empty ItemId for item: ${e['name']}");
        }

        return {
          "ItemId": rawId,
          "ItemType": "Food",
          "Quantity": int.tryParse(e['quantity'].toString()) ?? 1
        };
      }).toList();

      // FIXED: Removed the "request" wrapper.
      // Properties are now at the root level so the .NET backend can bind them correctly.
      final Map<String, dynamic> payload = {
        "Items": itemsPayload,
        "DeliveryAddress": address,
        "Latitude": latitude,
        "Longitude": longitude,
        "SpecialInstructions": instructions,
        "PrescriptionImageUrl": "",
        "CoinsToRedeem": 0
      };

      debugPrint("--- ATTEMPTING FOOD API CALL ---");
      debugPrint("Payload: $payload");

      final response = await _dio.post(
        BaseUrl.customerOrders,
        data: payload,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) onProgress(sent / total);
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'orderNumber': response.data['orderNumber'] ?? "N/A"
        };
      }
      return {'success': false, 'message': 'Status Code: ${response.statusCode}'};

    } on DioException catch (e) {
      debugPrint("Server Rejected: ${e.response?.data}");
      return {
        'success': false,
        'message': 'Validation Error: Check Item IDs or Address'
      };
    } catch (e) {
      return {'success': false, 'message': 'App Error: $e'};
    }
  }
}