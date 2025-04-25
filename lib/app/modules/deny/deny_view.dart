// deny_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 30),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You do not have permission to view this page.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Please check your credentials and try again.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Error Code: 403',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Get.offAllNamed('/login'),
              child: const Text('Return', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}