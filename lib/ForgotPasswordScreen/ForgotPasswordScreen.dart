import 'package:flutter/material.dart';
import 'ForgotPasswordController/ForgotPasswordController.dart';
import 'ResetPasswordScreen/ResetPasswordScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ForgotPasswordController _controller = ForgotPasswordController();

  // Updated Brand Color
  final Color themeColor = const Color(0xFFEB9F3F);

  // This dialog pops up after the "Send OTP" API call succeeds
  void _showOtpDialog() {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
            "Verify Email",
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("An OTP has been sent to your email. Please enter it below to proceed."),
            const SizedBox(height: 15),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              cursorColor: themeColor,
              decoration: InputDecoration(
                hintText: "Enter OTP Code",
                prefixIcon: Icon(Icons.security, color: themeColor),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () {
              if (otpController.text.trim().isNotEmpty) {
                String codeValue = otpController.text.trim();
                String emailValue = _emailController.text.trim();

                // 1. Close the Dialog
                Navigator.pop(context);

                // 2. Navigate to Reset screen, passing OTP into 'code'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(
                      email: emailValue,
                      code: codeValue, // This is passed as 'code' for the API
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter the OTP code"))
                );
              }
            },
            child: const Text("Verify Code", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(color: themeColor),
              child: const SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_reset, color: Colors.white, size: 80),
                    SizedBox(height: 10),
                    Text(
                        "Forgot Password",
                        style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 8),
                    Text(
                        "Verify your identity to reset password",
                        style: TextStyle(fontSize: 14, color: Colors.white70)
                    ),
                  ],
                ),
              ),
            ),

            // Input Card Section
            Padding(
              padding: const EdgeInsets.only(top: 300, left: 20, right: 20),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: themeColor,
                        decoration: InputDecoration(
                          hintText: "Enter Registered Email",
                          prefixIcon: Icon(Icons.email_outlined, color: themeColor),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300)
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ListenableBuilder ensures the button shows loading state
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              onPressed: _controller.isLoading ? null : () async {
                                if (_emailController.text.trim().isNotEmpty) {
                                  // Trigger the Send OTP API call
                                  bool success = await _controller.requestOtp(
                                      _emailController.text.trim(),
                                      context
                                  );

                                  // If API returns 200, show the OTP dialog
                                  if (success) {
                                    _showOtpDialog();
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter your email address"))
                                  );
                                }
                              },
                              child: _controller.isLoading
                                  ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text(
                                  "Send OTP",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                              "Back to Login",
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.w600)
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}