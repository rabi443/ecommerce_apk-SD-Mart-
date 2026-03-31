import 'package:flutter/material.dart';
import '../ForgotPasswordController/ForgotPasswordController.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final ForgotPasswordController _controller = ForgotPasswordController();

  // Updated Brand Color
  final Color themeColor = const Color(0xFFEB9F3F);

  bool _isObscure = true; // State for password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Set New Password", style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.vpn_key_outlined, size: 80, color: Color(0xFFEB9F3F)),
              const SizedBox(height: 20),
              const Text(
                  "Enter your new password below.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)
              ),
              const SizedBox(height: 30),
              _buildField(_passController, "New Password", Icons.lock_outline),
              const SizedBox(height: 16),
              _buildField(_confirmPassController, "Confirm Password", Icons.lock_reset),
              const SizedBox(height: 40),

              ListenableBuilder(
                  listenable: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: _controller.isLoading ? null : () {
                          if (_passController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Password cannot be empty"))
                            );
                          } else if (_passController.text == _confirmPassController.text) {
                            // Note: passing widget.code here
                            _controller.finalizeReset(
                                widget.email,
                                widget.code,
                                _passController.text,
                                context
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match!"))
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
                            "Reset Password",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      obscureText: _isObscure,
      cursorColor: themeColor,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: themeColor),
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}