import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/BaseUrl.dart';

class ReferralService {
  final Dio _dio = Dio();
  final GetStorage _box = GetStorage();

  /// Get referral info of logged-in user
  Future<Map<String, dynamic>> getMyReferralInfo() async {
    try {
      final token = _box.read("token");

      final response = await _dio.get(
        BaseUrl.referralInfo,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch referral info");
    }
  }
}
