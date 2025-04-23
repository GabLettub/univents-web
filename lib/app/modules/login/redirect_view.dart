import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RedirectView extends StatelessWidget {
  const RedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final controller = Get.find<LoginController>();
      final currentUser = Supabase.instance.client.auth.currentUser;


      if (currentUser == null) {
        controller.loginWithGoogle();  
      } else {
        controller.checkIfAdmin();     
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

