import 'package:get/get.dart';
import 'update_event_controller.dart';

class UpdateEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateEventController());
  }
}