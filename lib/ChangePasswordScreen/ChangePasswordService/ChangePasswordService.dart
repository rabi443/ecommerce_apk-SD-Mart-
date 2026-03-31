import 'package:dio/dio.dart';

import '../../core/BaseUrl.dart';


class ChangePasswordService {
  final Dio _dio = Dio();

  Future<Response> changePasswordApi({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    return await _dio.post(
      BaseUrl.changePassword,
      data: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}