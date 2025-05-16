import 'package:get/get.dart';
import 'update_organization_controller.dart';

class UpdateOrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateOrganizationController>(() => UpdateOrganizationController());
  }
}
