import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final name = TextEditingController();
  final description = TextEditingController();
  final logoUrl = RxnString();
  final logoBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final organizations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();
  }

  Future<void> fetchOrganizations() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('organizations').select();
      organizations.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      logoBytes.value = bytes;
    }
  }

  Future<void> createOrganization() async {
    isLoading.value = true;
    try {
      String? uploadedLogoUrl;

      if (logoBytes.value != null) {
        final fileName = 'org-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          logoBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        uploadedLogoUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      await supabase.from('organizations').insert({
        'name': name.text.trim(),
        'description': description.text.trim(),
        'logo': uploadedLogoUrl ?? logoUrl.value ?? '',
      });

      Get.back();
      Get.snackbar('Success', 'Organization created successfully');
      fetchOrganizations(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', 'Failed to create organization: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrganization(String uid) async {
    try {
      await supabase.from('organizations').delete().eq('uid', uid);
      organizations.removeWhere((org) => org['uid'] == uid);
      Get.snackbar('Deleted', 'Organization removed permanently',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete organization: $e');
    }
  }

  void goToCreateOrganization() {
    Get.toNamed('/create-organization');
  }
}
