import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002358), // Deep blue
      body: Center(
        child: _LoginCard(),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              child: Image.asset(
                'assets/univents_logo.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
              child: _GoogleSignInButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return ElevatedButton.icon(
      icon: Image.asset('assets/google_logo.png', height: 25),
      label: const Text('Sign In'),
      onPressed: controller.loginWithGoogle,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFF90CAF9)), // Light blue border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
