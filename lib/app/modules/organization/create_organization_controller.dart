import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateOrganizationController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Form Fields
  final name = TextEditingController();
  final acronym = TextEditingController();
  final category = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final facebook = TextEditingController();
  final description = TextEditingController();
  final status = RxString('active');

  // Banner & Logo Images
  final bannerBytes = Rxn<Uint8List>();
  final bannerUrl = RxnString();

  final logoBytes = Rxn<Uint8List>();
  final logoUrl = RxnString();

  final isLoading = false.obs;

  // Pick from local
  Future<void> pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      bannerBytes.value = bytes;
      bannerUrl.value = null;
    }
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      logoBytes.value = bytes;
      logoUrl.value = null;
    }
  }

  // Choose from bucket
  Future<void> selectBannerFromSupabase() async {
    await _selectImageFromBucket((url) {
      bannerUrl.value = url;
      bannerBytes.value = null;
    });
  }

  Future<void> selectLogoFromSupabase() async {
    await _selectImageFromBucket((url) {
      logoUrl.value = url;
      logoBytes.value = null;
    });
  }

  Future<void> _selectImageFromBucket(Function(String url) onSelect) async {
    try {
      final files = await supabase.storage.from('images').list();
      if (files.isEmpty) {
        Get.snackbar('No Images', 'No images found in the bucket.');
        return;
      }

      final selected = await Get.dialog<String>(
        SimpleDialog(
          title: const Text('Choose from Bucket'),
          children: files.map((file) {
            return SimpleDialogOption(
              onPressed: () => Get.back(result: file.name),
              child: Text(file.name),
            );
          }).toList(),
        ),
      );

      if (selected != null) {
        final url = supabase.storage.from('images').getPublicUrl(selected);
        onSelect(url);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> submitOrganization() async {
    isLoading.value = true;

    try {
      String? bannerPublicUrl;
      String? logoPublicUrl;

      if (bannerBytes.value != null) {
        final fileName = 'banner-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          bannerBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        bannerPublicUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      if (logoBytes.value != null) {
        final fileName = 'logo-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          logoBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        logoPublicUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      final data = {
        'name': name.text.trim(),
        'acronym': acronym.text.trim(),
        'category': category.text.trim(),
        'email': email.text.trim(),
        'mobile': mobile.text.trim(),
        'facebook': facebook.text.trim(),
        'status': status.value.toLowerCase(),
        'banner': bannerUrl.value ?? bannerPublicUrl,
        'logo': logoUrl.value ?? logoPublicUrl,
      };

      await supabase.from('organizations').insert(data);

      // ✅ Show success popup
      Get.snackbar(
        'Success',
        'Organization created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ Navigate to organization list after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed('/organizations'); // Change to your actual route if different
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
