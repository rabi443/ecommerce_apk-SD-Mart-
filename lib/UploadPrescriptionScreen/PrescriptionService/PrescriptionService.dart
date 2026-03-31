import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class PrescriptionService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final GetStorage _box = GetStorage();

  Future<Map<String, dynamic>> submitPrescription({
    required List<File> images,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? specialInstruction,
    Function(double progress)? onProgress,
  }) async {
    final token = _box.read('token');

    if (token == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final formData = FormData();

      if (description.trim().isNotEmpty) {
        formData.fields.add(MapEntry('orderDescription', description.trim()));
      }

      if (images.isNotEmpty) {
        final image = images.first;
        formData.files.add(
          MapEntry(
            'prescriptionImage',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      formData.fields.addAll([
        MapEntry('deliveryAddress', address),
        MapEntry('latitude', latitude.toString()),
        MapEntry('longitude', longitude.toString()),
        MapEntry('specialInstructions', specialInstruction?.trim() ?? ''),
      ]);

      final response = await _dio.post(
        BaseUrl.customerOrderReview,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }

      return {'success': false, 'message': 'Unexpected server response'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Upload failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }
}