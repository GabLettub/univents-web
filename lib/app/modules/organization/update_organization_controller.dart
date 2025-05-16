import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateOrganizationController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final name = TextEditingController();
  final acronym = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final facebook = TextEditingController();

  final category = RxString('cluster'); // 'cluster' or 'academic'
  final status = RxString('active');    // 'active' or 'hidden'

  final logoUrl = RxnString();
  final logoBytes = Rxn<Uint8List>();

  final bannerUrl = RxnString();
  final bannerBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isInitialized = false.obs;

  String? orgId;

  @override
  void onInit() {
    super.onInit();
    final org = Get.arguments;
    if (org != null && org is Map<String, dynamic>) {
      loadOrganizationData(org);
    } else {
      Get.snackbar('Error', 'Invalid organization data.');
      Get.offAllNamed('/organization-list');
    }
  }

  void loadOrganizationData(Map<String, dynamic> org) {
    orgId = org['uid']?.toString();
    name.text = org['name'] ?? '';
    acronym.text = org['acronym'] ?? '';
    category.value = (org['category'] ?? 'cluster').toString().toLowerCase();
    email.text = org['email'] ?? '';
    mobile.text = org['mobile'] ?? '';
    facebook.text = org['facebook'] ?? '';
    status.value = (org['status'] ?? 'active').toString().toLowerCase();
    logoUrl.value = org['logo'];
    bannerUrl.value = org['banner'];
    isInitialized.value = true;
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      logoBytes.value = await picked.readAsBytes();
      logoUrl.value = null; // Clear existing logo URL
    }
  }

  Future<void> pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      bannerBytes.value = await picked.readAsBytes();
      bannerUrl.value = null; // Clear existing banner URL
    }
  }

  Future<void> updateOrganization() async {
    if (orgId == null || orgId!.isEmpty) {
      Get.snackbar('Error', 'Missing organization ID.');
      return;
    }

    isLoading.value = true;

    try {
      String? uploadedLogoUrl;
      String? uploadedBannerUrl;

      if (logoBytes.value != null) {
        final fileName = 'org-logo-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          logoBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        uploadedLogoUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      if (bannerBytes.value != null) {
        final fileName = 'org-banner-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          bannerBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        uploadedBannerUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      final updatedData = {
        'name': name.text.trim(),
        'acronym': acronym.text.trim(),
        'category': category.value.trim(),
        'email': email.text.trim(),
        'mobile': mobile.text.trim(),
        'facebook': facebook.text.trim(),
        'status': status.value.trim(),
        'logo': uploadedLogoUrl ?? logoUrl.value ?? '',
        'banner': uploadedBannerUrl ?? bannerUrl.value ?? '',
      };

      final response = await supabase
          .from('organizations')
          .update(updatedData)
          .eq('uid', orgId)
          .select();

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No data returned after update. Possible invalid UID.');
      }

      Get.snackbar(
        'Success',
        'Organization updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/organizations', arguments: {'refresh': true});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
