import 'package:get/get.dart';
import '../ReferralService/ReferralService.dart';

class ReferralController extends GetxController {
  final ReferralService _service = ReferralService();

  /// API data
  final referralCode = "".obs;
  final totalReferrals = 0.obs;
  final totalBonusCoins = 0.obs;
  final recentReferrals = [].obs;

  /// Registration-time referral input
  final enteredReferralCode = "".obs;

  final isLoading = false.obs;

  /// Fetch referral info after login or after entering a referral code
  Future<void> loadReferralInfo() async {
    try {
      isLoading.value = true;

      final data = await _service.getMyReferralInfo();

      referralCode.value = data["referralCode"] ?? "";
      totalReferrals.value = data["totalReferrals"] ?? 0;
      totalBonusCoins.value = data["totalBonusCoins"] ?? 0; // ✅ fetch from backend
      recentReferrals.value = data["recentReferrals"] ?? [];
    } catch (e) {
      Get.snackbar("Error", "Unable to load referral info");
    } finally {
      isLoading.value = false;
    }
  }

  /// Save referral code entered by user
  void setReferralCode(String code) {
    enteredReferralCode.value = code.trim();
  }

  /// Used in register API
  String getReferralCodeForRegister() {
    return enteredReferralCode.value;
  }
}
