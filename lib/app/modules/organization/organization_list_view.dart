import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'organization_controller.dart';

class OrganizationListView extends GetView<OrganizationController> {
  const OrganizationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.organizations.isEmpty) {
          return const Center(child: Text('No organizations found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.organizations.length,
          itemBuilder: (context, index) {
            final org = controller.organizations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: org['logo'] != null && org['logo'] != ''
                    ? Image.network(org['logo'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.business),
                title: Text(org['name'] ?? 'No name'),
                subtitle: Text(org['description'] ?? 'No description'),
                onTap: () {
                  // TODO: navigate to update org / view members
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCreateOrganization,
        child: const Icon(Icons.add),
      ),
    );
  }
}
