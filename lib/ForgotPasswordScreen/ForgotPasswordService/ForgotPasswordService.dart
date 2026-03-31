import 'package:dio/dio.dart';
import '../../core/BaseUrl.dart';

class ForgotPasswordService {
  final Dio _dio = Dio();

  Future<Response> sendOtp(String email) async {
    return await _dio.post(
      BaseUrl.forgotPassword,
      data: {'email': email},
    );
  }

  Future<Response> resetPassword(String email, String code, String newPassword) async {
    return await _dio.post(
      BaseUrl.resetPassword,
      data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }
}