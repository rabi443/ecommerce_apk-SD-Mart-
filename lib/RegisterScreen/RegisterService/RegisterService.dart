import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/BaseUrl.dart';

class RegisterService {
  static Future<void> registerCustomer({
    required String username,
    required String email,
    required String phone,
    required String address,
    required String password,
    String? referralCode,
  }) async {
    final Map<String, dynamic> body = {
      "name": username,
      "email": email,
      "phone": phone,
      "address": address,
      "password": password,
      "confirmPassword": password,
    };

    if (referralCode != null && referralCode.isNotEmpty) {
      body["referralCode"] = referralCode;
    }

    final response = await http.post(
      Uri.parse(BaseUrl.registerCustomer),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Registration failed");
    }
  }

  static Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse(BaseUrl.verifyEmail),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "code": otp,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Invalid OTP");
    }
  }
}