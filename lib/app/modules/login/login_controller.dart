import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final supabase = Supabase.instance.client;

  Future<void> loginWithGoogle() async {
    try {
      final response = await supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'http://localhost:3000', // or your deployed domain
      );

      // The actual redirect is handled by Supabase and browser
      // This is just to await session completion
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    }
  }

  // Called after redirect to check session
  void checkIfAdmin() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;

    if (user == null) {
      Get.offAllNamed('/login');
      return;
    }

    // Basic admin check
    final email = user.email ?? '';
    final isAdmin =
        email == 'admin@example.com'; // Or add email to user_metadata

    if (isAdmin) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Access Denied', 'You are not an admin.');
      await supabase.auth.signOut();
      Get.offAllNamed('/login');
    }
  }
}
