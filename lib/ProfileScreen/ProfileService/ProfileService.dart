import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class ProfileService {
  static final Dio _dio = Dio();
  static final GetStorage box = GetStorage();

  static Options _getOptions() => Options(headers: {"Authorization": "Bearer ${box.read('token')}"});

  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dio.get(BaseUrl.customerProfile, options: _getOptions());
      return response.statusCode == 200 ? response.data : null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> jsonData, File? imageFile) async {
    try {
      Map<String, dynamic> payload = Map.from(jsonData);
      if (imageFile != null) {
        payload["image"] = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
      }
      FormData formData = FormData.fromMap(payload);
      final response = await _dio.put(BaseUrl.customerProfile, options: _getOptions(), data: formData);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}