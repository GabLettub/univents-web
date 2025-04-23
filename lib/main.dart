import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter_web_plugins/url_strategy.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  await Supabase.initialize(
    url: 'https://nbtooqanjpuitygixrmc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5idG9vcWFuanB1aXR5Z2l4cm1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1Mjk0NDEsImV4cCI6MjA2MDEwNTQ0MX0.zpfG3qR1cdYYSGT4CIBqcUX736mwvVDB36agYg-yQsI',
  );
  //Get.put(LoginController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Univents',
      //initialRoute: AppPages.INITIAL,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: AppPages.routes,
    );
  }
}
