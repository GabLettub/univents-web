import 'package:get/get.dart';
import '../modules/login/login_view.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/redirect_view.dart';
import '../modules/home/home_binding.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(name: '/login', page: () => LoginView(), binding: LoginBinding()),
    GetPage(name: '/home', page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: '/redirect', page: () => const RedirectView(), binding: RedirectBinding()),
  ];
}
