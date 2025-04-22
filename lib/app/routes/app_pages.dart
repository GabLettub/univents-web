import 'package:get/get.dart';
import '../modules/login/login_view.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/splash/splash_view.dart';


class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(name: '/splash', page: () => SplashView()),
    GetPage(name: '/login',page: () => LoginView(),binding: LoginBinding()),
    GetPage(name: '/home', page: () => HomeView()),
  ];
}
