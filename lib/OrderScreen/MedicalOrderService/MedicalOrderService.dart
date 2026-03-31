import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/BaseUrl.dart';

class MedicalOrderService {
  final GetStorage box = GetStorage();

  Future<List<dynamic>> fetchCustomerOrders() async {
    try {
      String? token = box.read('token');

      if (token == null || token.isEmpty) {
        throw Exception("Auth token is missing. Please log in again.");
      }

      final response = await http.get(
        Uri.parse(BaseUrl.customerHistory),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15)); // Prevents infinite loading

      debugPrint("--- Order API Status: ${response.statusCode} ---");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];

        var data = json.decode(response.body);

        // Handle every possible way the .NET backend might wrap the data
        if (data is List) return data;

        if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) return data['data'];
          if (data.containsKey('result') && data['result'] is List) return data['result'];
          if (data.containsKey('items') && data['items'] is List) return data['items'];
          if (data.containsKey('orders') && data['orders'] is List) return data['orders'];
          if (data.containsKey('Data') && data['Data'] is List) return data['Data']; // PascalCase check

          return []; // Returns empty if it's a map but has no recognizable list
        }
        return [];
      } else {
        // Throws exact server error (e.g., 401 Unauthorized)
        throw Exception("Server Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("MedicalOrderService Error: $e");
      rethrow;
    }
  }
}