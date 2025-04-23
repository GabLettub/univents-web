import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

class LoginController extends GetxController {
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

    //auth state change
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        //delay to avoid dups on keys
        Future.delayed(Duration(milliseconds: 100), () {
          checkIfAdmin();
        });
      }
    });
  }


  Future<void> loginWithGoogle() async {
    try {
      final origin = web.window.location.origin;
      await supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: origin, 
      );


    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    }
  }

  //check email if admin
  void checkIfAdmin() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final email = user.email ?? '';
    if (email == 'rasceniza@addu.edu.ph') {
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } else {
      Get.snackbar('Access Denied', 'You are not an admin.');
      supabase.auth.signOut();
      Get.offAllNamed('/login');
    }
  }
}
