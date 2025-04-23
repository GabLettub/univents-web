import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashView extends StatelessWidget {
  final supabase = Supabase.instance.client;

   SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkSession(),
      builder: (context, snapshot) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = Supabase.instance.client.auth.currentSession;
    final email = session?.user.email ?? '';

    Future.microtask(() {
      if (email == 'admin@example.com') {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }
}
