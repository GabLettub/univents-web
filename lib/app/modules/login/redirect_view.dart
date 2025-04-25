import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RedirectView extends StatelessWidget {
  const RedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      try {
        final controller = Get.find<LoginController>();
        
        await Future.delayed(const Duration(milliseconds: 400));

        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          Get.offAllNamed('/login');
        } else {
          controller.checkIfAdmin();
        }   
      } catch (e) {
        debugPrint('Redirect error: $e');
        Get.offAllNamed('/login');
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
