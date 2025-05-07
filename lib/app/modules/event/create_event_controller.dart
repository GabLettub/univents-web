import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final tags = TextEditingController();

  final type = ''.obs;
  final selectedOrgUid = ''.obs;
  final organizations = <Map<String, dynamic>>[].obs;
  final status = RxString('pending');

  final datetimeStart = Rxn<DateTime>();
  final datetimeEnd = Rxn<DateTime>();

  final banner = Rxn<File>();
  final bannerBytes = Rxn<Uint8List>();
  final bannerUrl = RxnString();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();
  }

  Future<void> fetchOrganizations() async {
    try {
      final response = await supabase.from('organizations').select('uid, name');
      organizations.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizations: $e');
    }
  }

  Future<void> pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      bannerBytes.value = await picked.readAsBytes();
      bannerUrl.value = null;
    }
  }

  Future<void> selectFromSupabase() async {
    try {
      final files = await supabase.storage.from('images').list();
      if (files.isEmpty) {
        Get.snackbar('No Images', 'No images found in the bucket.');
        return;
      }

      final selected = await Get.dialog<String>(
        SimpleDialog(
          title: const Text('Choose Existing Banner'),
          children: files.map((f) {
            return SimpleDialogOption(
              child: Text(f.name),
              onPressed: () => Get.back(result: f.name),
            );
          }).toList(),
        ),
      );

      if (selected != null) {
        final url = supabase.storage.from('images').getPublicUrl(selected);
        banner.value = File('');
        bannerUrl.value = url;
        bannerBytes.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> submitEvent() async {
    isLoading.value = true;

    try {
      if (title.text.trim().isEmpty || type.value.trim().isEmpty) {
        Get.snackbar('Validation Error', 'Title and type are required');
        return;
      }

      String? imageUrl;
      if (bannerBytes.value != null) {
        final fileName = 'event-${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('images').uploadBinary(
          fileName,
          bannerBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        imageUrl = supabase.storage.from('images').getPublicUrl(fileName);
      }

      final data = {
        'title': title.text.trim(),
        'description': description.text.trim(),
        'location': location.text.trim(),
        'type': type.value.trim(),
        'tags': tags.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'datetimestart': datetimeStart.value?.toIso8601String(),
        'datetimeend': datetimeEnd.value?.toIso8601String(),
        'status': status.value.toLowerCase(),
        'orguid': selectedOrgUid.value,
        'banner': bannerUrl.value ?? imageUrl,
      };

      await supabase.from('events').insert(data);

      Get.snackbar(
        'Success',
        'Event created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home', arguments: {'refresh': true});
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event');
    } finally {
      isLoading.value = false;
    }
  }
}
