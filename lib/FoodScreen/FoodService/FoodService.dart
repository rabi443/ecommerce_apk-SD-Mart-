import 'package:dio/dio.dart';
import '../../core/BaseUrl.dart';

class FoodService {
  final Dio _dio = Dio();

  Future<List<dynamic>> getAllFoodItems() async {
    try {
      final response = await _dio.get(BaseUrl.allFoodItems);
      // Handles both { items: [] } and direct list []
      return response.data is Map ? (response.data['items'] ?? []) : response.data;
    } catch (e) { rethrow; }
  }

  Future<List<dynamic>> getFoodCategories() async {
    try {
      final response = await _dio.get(BaseUrl.foodCategories);
      return response.data;
    } catch (e) { rethrow; }
  }

  Future<List<dynamic>> getFoodByCategory(String categoryId) async {
    try {
      final response = await _dio.get(BaseUrl.getFoodByCategory(categoryId));
      return response.data;
    } catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> getFoodItemDetails(String itemId) async {
    try {
      final url = BaseUrl.getMenuItemById(itemId);
      print("API CALL: $url"); // Check if this URL is correct in your terminal
      final response = await _dio.get(url);
      return response.data;
    } catch (e) { rethrow; }
  }
}