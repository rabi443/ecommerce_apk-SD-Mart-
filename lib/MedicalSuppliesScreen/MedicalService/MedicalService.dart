import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/BaseUrl.dart';

class MedicalService {
  static String formatImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return "";
    String baseUrl = BaseUrl.base_url;
    if (!baseUrl.endsWith('/') && !rawPath.startsWith('/')) {
      return "$baseUrl/$rawPath";
    } else if (baseUrl.endsWith('/') && rawPath.startsWith('/')) {
      return baseUrl + rawPath.substring(1);
    } else {
      return baseUrl + rawPath;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMedicines() async {
    final response = await http.get(Uri.parse(BaseUrl.medicines));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          "id": item["medicineId"] ?? item["id"],
          "name": item["name"] ?? "Unknown Medicine",
          "price": (item["price"] ?? 0).toDouble(),
          "rating": 4.0,
          "description": item["description"] ?? "No description available",
          "imageUrl": formatImageUrl(item["imageUrl"] ?? item["image"]),
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch medicines");
    }
  }
}