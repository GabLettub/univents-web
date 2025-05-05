import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_organization_controller.dart';

class CreateOrganizationView extends GetView<CreateOrganizationController> {
  const CreateOrganizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Organization')),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _textField(controller.name, 'Name'),
                    _textField(controller.acronym, 'Acronym'),
                    _textField(controller.category, 'Category'),
                    _textField(controller.email, 'Email'),
                    _textField(controller.mobile, 'Mobile'),
                    _textField(controller.facebook, 'Facebook URL'),
                    _textField(controller.description, 'Description'),
                    _dropdownStatus(),
                    const SizedBox(height: 10),
                    _bannerUpload(),
                    const SizedBox(height: 10),
                    _logoUpload(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.submitOrganization,
                      child: const Text('Submit Organization'),
                    )
                  ],
                ),
              );
      }),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _dropdownStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.status.value.toLowerCase(),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
            ],
            onChanged: (val) => controller.status.value = val ?? 'active',
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          )),
    );
  }

  Widget _bannerUpload() {
    return Column(
      children: [
        const Text('Organization Banner'),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.bannerBytes.value != null) {
            return Image.memory(controller.bannerBytes.value!, height: 150);
          } else if (controller.bannerUrl.value != null) {
            return Image.network(controller.bannerUrl.value!, height: 150);
          } else {
            return const Text('No image selected');
          }
        }),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: controller.pickBanner,
              child: const Text('Upload from PC'),
            ),
            ElevatedButton(
              onPressed: controller.selectBannerFromSupabase,
              child: const Text('Choose from Bucket'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logoUpload() {
    return Column(
      children: [
        const Text('Organization Logo'),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.logoBytes.value != null) {
            return Image.memory(controller.logoBytes.value!, height: 100);
          } else if (controller.logoUrl.value != null) {
            return Image.network(controller.logoUrl.value!, height: 100);
          } else {
            return const Text('No logo selected');
          }
        }),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: controller.pickLogo,
              child: const Text('Upload Logo from PC'),
            ),
            ElevatedButton(
              onPressed: controller.selectLogoFromSupabase,
              child: const Text('Choose Logo from Bucket'),
            ),
          ],
        ),
      ],
    );
  }
}
