import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Theme Color
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPolicySection(
                    icon: Icons.info_outline_rounded,
                    title: "Information We Collect",
                    content: "• Name, email, phone number\n"
                        "• Shipping and billing address\n"
                        "• Order details\n"
                        "• Device information, IP address, and app usage data",
                  ),
                  _buildPolicySection(
                    icon: Icons.settings_suggest_outlined,
                    title: "How We Use Your Information",
                    content: "• To create and manage user accounts\n"
                        "• To process orders and deliver products\n"
                        "• To provide customer support\n"
                        "• To improve app performance and user experience\n"
                        "• To comply with legal requirements in Nepal",
                  ),
                  _buildPolicySection(
                    icon: Icons.share_outlined,
                    title: "Data Sharing",
                    content: "We do not sell personal data. Information may be shared only with:\n"
                        "• Payment gateways and delivery partners\n"
                        "• Service providers required for app functionality\n"
                        "• Legal authorities when required by law",
                  ),
                  _buildPolicySection(
                    icon: Icons.security_outlined,
                    title: "Data Security",
                    content: "We use reasonable security measures to protect your data from unauthorized access or disclosure.",
                  ),
                  _buildPolicySection(
                    icon: Icons.how_to_reg_outlined,
                    title: "User Rights",
                    content: "You may access, update, or request deletion of your data by contacting us directly through the support email.",
                  ),
                  _buildPolicySection(
                    icon: Icons.child_care_outlined,
                    title: "Children’s Privacy",
                    content: "This app is not intended for users under 18 years of age. We do not knowingly collect data from minors.",
                  ),

                  const SizedBox(height: 20),

                  // Contact Card
                  _buildContactCard(),

                  const SizedBox(height: 40),
                  Text(
                    "Last updated: February 2026",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.privacy_tip_rounded, size: 60, color: Colors.white),
          const SizedBox(height: 15),
          const Text(
            "SDMart Privacy Policy",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Effective Date: 1st February, 2026",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({required IconData icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Have Questions?",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Icon(Icons.email_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("sdmart.support@gmail.com", style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Biratnagar, Nepal", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}