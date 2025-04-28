// app_pages.dart
import 'package:get/get.dart';
import 'package:univents/app/modules/event/event_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/home/home_binding.dart';
import '../modules/login/redirect_view.dart';
import '../modules/deny/deny_view.dart';
import '../modules/event/event_details_view.dart'; 
import '../modules/event/event_binding.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(name: '/login', page: () => LoginView(), binding: LoginBinding()),
    GetPage(name: '/home', page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: '/redirect', page: () => const RedirectView(), binding: LoginBinding()),
    GetPage(name: '/access-denied', page: () => const AccessDeniedView()),
    GetPage(name: '/event-details', page: () => const EventDetailsView(), binding: EventBinding()), 
  ];
}