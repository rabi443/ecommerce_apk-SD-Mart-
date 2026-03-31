import 'package:dio/dio.dart';
import '../../core/BaseUrl.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoginService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final Dio dio = Dio();

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    try {
      final Response<Map<String, dynamic>> response = await dio.post<Map<String, dynamic>>(
        BaseUrl.login,
        data: {
          "email": email.trim(),
          "password": password,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data ?? {};
    } on DioException catch (e) {
      rethrow;
    }
  }
}