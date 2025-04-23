import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;
import 'dart:html' as html;

class LoginController extends GetxController {
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    //auth state change
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      if (session != null && event == AuthChangeEvent.signedIn) {
        //delay to avoid dups on keys
        Future.delayed(const Duration(milliseconds: 100), () {
          checkIfAdmin();
        });
      }
    });
  }

  Future<void> loginWithGoogle() async {
    try {

      await Supabase.instance.client.auth.signOut();
      html.window.localStorage.remove('supabase.auth.token');
      html.window.localStorage.remove('supabase.auth.user');


      final origin = web.window.location.origin;
      await supabase.auth.signInWithOAuth(
        Provider.google,
        redirectTo: '$origin/redirect',
        scopes: 'email profile',
        queryParams: {
          'prompt': 'select_account', 
        },
      );
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    }
  }



  //check email if admin
  void checkIfAdmin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final role = user.userMetadata?['role'];
    print('Role = $role');

    if (role == 'admin') {
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } else {
      Get.snackbar('Access Denied', 'You are not an admin.');
      await supabase.auth.signOut();

      html.window.localStorage.remove('supabase.auth.token');
      html.window.localStorage.remove('supabase.auth.user');


      await Future.delayed(const Duration(milliseconds: 300));


      Get.offAllNamed('/login');
    }
  }

  void logout() async {
    await supabase.auth.signOut();

    html.window.localStorage.remove('supabase.auth.token');
    html.window.localStorage.remove('supabase.auth.user');

    await Future.delayed(const Duration(milliseconds: 300));

    // Force browser to flush IndexedDB & memory cache
    Get.offAllNamed('/login'); 

    // Not needed if you're reloading the page
    // Get.offAllNamed('/login');
  }
}
