import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../LoginScreen/LoginScreen.dart';
import 'RegisterController/RegisterController.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Updated Color Theme
  final Color themeColor = const Color(0xFFEB9F3F);
  final RegisterController controller = Get.put(RegisterController());

  final FocusNode usernameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode referralFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  final FocusNode confirmPassFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Re-trigger build on focus change to update icon colors
    usernameFocus.addListener(() => setState(() {}));
    emailFocus.addListener(() => setState(() {}));
    phoneFocus.addListener(() => setState(() {}));
    addressFocus.addListener(() => setState(() {}));
    referralFocus.addListener(() => setState(() {}));
    passFocus.addListener(() => setState(() {}));
    confirmPassFocus.addListener(() => setState(() {}));
  }

  InputDecoration inputField(String label, IconData icon, FocusNode focusNode, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: focusNode.hasFocus ? themeColor : Colors.grey),
      floatingLabelStyle: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
      hintText: "Enter $label",
      prefixIcon: Icon(icon, color: focusNode.hasFocus ? themeColor : Colors.grey),
      suffixIcon: suffixIcon,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeColor, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: controller.username,
              focusNode: usernameFocus,
              decoration: inputField("Username", Icons.person, usernameFocus),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.email,
              focusNode: emailFocus,
              decoration: inputField("Email", Icons.email, emailFocus),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.phone,
              keyboardType: TextInputType.phone,
              focusNode: phoneFocus,
              decoration: inputField("Phone Number", Icons.phone, phoneFocus),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.address,
              focusNode: addressFocus,
              decoration: inputField("Address", Icons.location_on, addressFocus),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.referralCode,
              focusNode: referralFocus,
              decoration: inputField("Referral Code (Optional)", Icons.card_giftcard, referralFocus),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.password,
              obscureText: !_isPasswordVisible,
              focusNode: passFocus,
              decoration: inputField(
                "Password",
                Icons.lock,
                passFocus,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: themeColor),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller.confirmPassword,
              obscureText: !_isConfirmPasswordVisible,
              focusNode: confirmPassFocus,
              decoration: inputField(
                "Confirm Password",
                Icons.lock_outline,
                confirmPassFocus,
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: themeColor),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                onPressed: () async {
                  await controller.register();
                },
                child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () => Get.to(() => const LoginScreen()),
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}