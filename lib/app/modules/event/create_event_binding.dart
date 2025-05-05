import 'package:get/get.dart';
import 'create_event_controller.dart';

class CreateEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateEventController());
  }
}
