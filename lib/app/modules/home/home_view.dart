import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_controller.dart'; 
import 'dart:ui';

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
            child: IconButton(
              tooltip: 'Logout',
              onPressed: controller.logout,
              icon: const Icon(Icons.power_settings_new),
              iconSize: 24,
              color: Colors.white,
              splashRadius: 24,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/addu_banner.png', fit: BoxFit.cover),
          ),

          // Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3.0, // Horizontal blur
                sigmaY: 3.0, // Vertical blur
              ),
              child: Container(
                color: Colors.black.withOpacity(
                  0,
                ), // Keep this to allow blur but no color
              ),
            ),
          ),

          // Foreground Content
          const Center(
            child: Text(
              'Welcome Admin?',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
