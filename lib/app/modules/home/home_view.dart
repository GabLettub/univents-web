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
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: controller.logout,
          ),
        ],
      ),
      body: const Center(child: Text('Welcome Admin')),
    );
  }
}
