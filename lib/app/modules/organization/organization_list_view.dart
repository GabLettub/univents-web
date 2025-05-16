import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'organization_controller.dart';

class OrganizationListView extends GetView<OrganizationController> {
  const OrganizationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.offAllNamed('/home'),
        ),
      ),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.organizations.isEmpty) {
          return const Center(child: Text('No organizations found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.organizations.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final org = controller.organizations[index];
            return GestureDetector(
              onTap: () {
                Get.toNamed('/organization-details', arguments: org);
                print('Tapped org: $org');
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (org['logo'] != null && org['logo'] != '')
                          Center(
                            child: ClipOval(
                              child: Image.network(
                                org['logo'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.business),
                              ),
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 35,
                            child: Icon(Icons.business),
                          ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            org['name'] ?? 'No name',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            controller.deleteOrganization(org['uid']),
                      ),
                    ),
                  ],
                ),
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
