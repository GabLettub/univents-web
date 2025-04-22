import 'package:get/get.dart';
import '../modules/login/login_view.dart';
import '../modules/home/home_view.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(name: '/login', page: () => LoginView()),
    GetPage(name: '/home', page: () => HomeView()),
  ];
}
