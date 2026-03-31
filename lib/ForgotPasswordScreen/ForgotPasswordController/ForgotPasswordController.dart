import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../ForgotPasswordService/ForgotPasswordService.dart';

class ForgotPasswordController extends ChangeNotifier {
  final ForgotPasswordService _service = ForgotPasswordService();
  bool isLoading = false;

  Future<bool> requestOtp(String email, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _service.sendOtp(email);
      return response.statusCode == 200;
    } on DioException catch (e) {
      _showError(context, _extractErrorMessage(e));
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finalizeReset(String email, String code, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _service.resetPassword(email, code, password);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess(context, "Password reset successfully!");
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on DioException catch (e) {
      _showError(context, _extractErrorMessage(e));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper to get exact error message from API
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? e.response?.data['error'] ?? "Action failed";
    }
    return e.message ?? "An unexpected error occurred";
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF02754B)));
  }
}