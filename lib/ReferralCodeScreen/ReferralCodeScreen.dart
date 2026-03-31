import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'ReferralController/ReferralController.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  // Brand Colors
  final Color primaryColor = const Color(0xFFEB9F3F);
  final Color secondaryColor = const Color(0xFFF3B05A);
  final Color bgColor = const Color(0xFFF8F9FA);

  final ReferralController referralCtrl = Get.put(ReferralController());

  @override
  void initState() {
    super.initState();
    referralCtrl.loadReferralInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Refer & Earn",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async => await referralCtrl.loadReferralInfo(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- HEADER SECTION WITH COIN BALANCE ---
              _buildHeaderBalance(),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- REFERRAL CODE SECTION ---
                    _buildReferralCodeCard(),

                    const SizedBox(height: 30),

                    // --- HOW IT WORKS SECTION ---
                    const Text(
                      "How it works",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildStepTile(
                      icon: Icons.share_outlined,
                      title: "Share your code",
                      subtitle: "Invite your friends to join using your unique code.",
                    ),
                    _buildStepTile(
                      icon: Icons.person_add_alt_outlined,
                      title: "Friend signs up",
                      subtitle: "They register on the app for the first time.",
                    ),
                    _buildStepTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "You get rewarded",
                      subtitle: "Receive bonus coins instantly in your wallet!",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header Balance Widget
  Widget _buildHeaderBalance() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      child: Column(
        children: [
          Obx(() => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/coin.png',
                  height: 60,
                  width: 60,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.stars, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                referralCtrl.isLoading.value
                    ? "..."
                    : referralCtrl.totalBonusCoins.value.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Total Coins Earned",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // 2. Referral Code Card Widget
  Widget _buildReferralCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "YOUR REFERRAL CODE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            String code = referralCtrl.referralCode.value.isEmpty
                ? "-------"
                : referralCtrl.referralCode.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Get.snackbar(
                      "Copied!",
                      "Referral code copied to clipboard",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: primaryColor,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                )
              ],
            );
          }),
          const Divider(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Logic to share code
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "REFER A FRIEND",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 3. Step Tile Widget
  Widget _buildStepTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}