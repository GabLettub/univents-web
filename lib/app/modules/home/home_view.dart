// home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_controller.dart';
import 'dart:ui';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final userEmail = controller.supabase.auth.currentUser?.email ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Welcome, $userEmail'),
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
          Positioned.fill(
            child: Image.asset('assets/addu_banner.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(color: Colors.black.withOpacity(0)),
            ),
          ),
          const Center(
            child: Text(
              'Admin Panel',
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