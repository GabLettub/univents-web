import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationDetailsView extends StatelessWidget {
  const OrganizationDetailsView({super.key});

  Future<Map<String, dynamic>?> _fetchOrganization(String orgId) async {
    try {
      final response = await Supabase.instance.client
          .from('organizations')
          .select()
          .eq('uid', orgId)
          .single();
      return response;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organization details');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final organization = Get.arguments as Map<String, dynamic>?;

    if (organization == null) {
      // fallback or redirect
      Future.microtask(() => Get.offAllNamed('/organization-list'));
      return const _LoadingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(organization['acronym'] ?? 'Organization Details'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final orgId = organization['uid'];
              if (orgId == null || orgId.toString().isEmpty) {
                Get.snackbar('Error', 'Missing organization UID');
                return;
              }

              try {
                final fullOrg = await _fetchOrganization(orgId);
                if (fullOrg != null) {
                  await Get.toNamed('/edit-organization', arguments: fullOrg);
                } else {
                  Get.snackbar('Error', 'Organization not found');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to load organization: $e');
              }
            },
          ),
        ],
      ),
      body: _OrganizationDetailsBody(organization: organization),
    );
  }

  void _redirectToHome() {
    Future.microtask(() => Get.offAllNamed('/home'));
  }
}

class _OrganizationDetailsBody extends StatelessWidget {
  final Map<String, dynamic> organization;

  const _OrganizationDetailsBody({required this.organization});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (organization['banner'] != null)
            _OrgBanner(imageUrl: organization['banner']),
          const SizedBox(height: 16),
          if (organization['logo'] != null)
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(organization['logo']),
                radius: 40,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            organization['name'] ?? 'No Name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (organization['acronym'] != null)
            Text(
              organization['acronym'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Category', value: organization['category']),
          _InfoRow(label: 'Email', value: organization['email']),
          _InfoRow(label: 'Mobile', value: organization['mobile']),
          _InfoRow(label: 'Facebook', value: organization['facebook']),
          _InfoRow(label: 'Status', value: organization['status']),
        ],
      ),
    );
  }
}

class _OrgBanner extends StatelessWidget {
  final String imageUrl;

  const _OrgBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, softWrap: true),
          ),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
