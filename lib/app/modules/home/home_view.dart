import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_controller.dart'; // adjust path if needed

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      title: const Text('Admin Home'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            onPressed: controller.logout,
          ),
        ),
      ],
    ),

    );
  }
}
