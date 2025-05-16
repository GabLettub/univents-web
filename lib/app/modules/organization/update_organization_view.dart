import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_organization_controller.dart';

class UpdateOrganizationView extends GetView<UpdateOrganizationController> {
  const UpdateOrganizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Organization')),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _textField(controller.name, 'Name'),
              _textField(controller.acronym, 'Acronym'),
              _categoryDropdown(),
              _statusDropdown(),
              _textField(controller.email, 'Email'),
              _textField(controller.mobile, 'Mobile'),
              _textField(controller.facebook, 'Facebook'),
              const SizedBox(height: 16),
              _bannerPreview(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: controller.pickBanner,
                icon: const Icon(Icons.image),
                label: const Text('Upload Banner'),
              ),
              const SizedBox(height: 20),
              _logoPreview(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: controller.pickLogo,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Logo'),
              ),
              const SizedBox(height: 20),
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: controller.updateOrganization,
                      child: const Text('Update Organization'),
                    )),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    final categories = ['cluster', 'academic'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.category.value.isEmpty ? null : controller.category.value,
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat.capitalizeFirst!),
                    ))
                .toList(),
            onChanged: (val) => controller.category.value = val ?? 'cluster',
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          )),
    );
  }

  Widget _statusDropdown() {
    final statuses = ['active', 'hidden'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.status.value.isEmpty ? null : controller.status.value,
            items: statuses
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.capitalizeFirst!),
                    ))
                .toList(),
            onChanged: (val) => controller.status.value = val ?? 'active',
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
          )),
    );
  }

  Widget _logoPreview() {
    return Obx(() {
      if (controller.logoBytes.value != null) {
        return Image.memory(controller.logoBytes.value!, height: 100);
      } else if (controller.logoUrl.value != null && controller.logoUrl.value!.isNotEmpty) {
        return Image.network(controller.logoUrl.value!, height: 100);
      } else {
        return const Text('No logo selected');
      }
    });
  }

  Widget _bannerPreview() {
    return Obx(() {
      if (controller.bannerBytes.value != null) {
        return Image.memory(controller.bannerBytes.value!, height: 150);
      } else if (controller.bannerUrl.value != null && controller.bannerUrl.value!.isNotEmpty) {
        return Image.network(controller.bannerUrl.value!, height: 150);
      } else {
        return const Text('No banner selected');
      }
    });
  }
}
