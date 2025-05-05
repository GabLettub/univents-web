import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Text controllers
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final type = TextEditingController();
  final tags = TextEditingController();

  // Dropdown values
  final selectedOrgUid = ''.obs;
  final organizations = <Map<String, dynamic>>[].obs;
  final status = RxString('pending');

  // Date pickers
  final datetimeStart = Rxn<DateTime>();
  final datetimeEnd = Rxn<DateTime>();

  // Banner image
  final banner = Rxn<File>();
  final bannerBytes = Rxn<Uint8List>();
  final bannerUrl = RxnString();

  // Flags
  final isLoading = false.obs;
  final isInitialized = false.obs;

  // Internal Event ID
  String? eventId;

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      prefillForm(args);
    }
  }

  void prefillForm(Map<String, dynamic> event) {
    eventId = event['id']?.toString();  // ✅ Assign event ID here

    title.text = event['title'] ?? '';
    description.text = event['description'] ?? '';
    location.text = event['location'] ?? '';
    type.text = event['type'] ?? '';
    tags.text = (event['tags'] as List?)?.join(', ') ?? '';
    selectedOrgUid.value = event['orguid'] ?? '';
    status.value = event['status'] ?? 'pending';
    bannerUrl.value = event['banner'];

    datetimeStart.value = event['datetimestart'] != null
        ? DateTime.tryParse(event['datetimestart'])
        : null;

    datetimeEnd.value = event['datetimeend'] != null
        ? DateTime.tryParse(event['datetimeend'])
        : null;

    isInitialized.value = true;
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
      final bytes = await picked.readAsBytes();
      bannerBytes.value = bytes;
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
        banner.value = File(''); // dummy
        bannerUrl.value = url;
        bannerBytes.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> submitEvent({bool isEditing = false, String? eventId}) async {
    isLoading.value = true;

    try {
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
        'title': title.text,
        'description': description.text,
        'location': location.text,
        'type': type.text,
        'tags': tags.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'datetimestart': datetimeStart.value?.toIso8601String(),
        'datetimeend': datetimeEnd.value?.toIso8601String(),
        'status': status.value.toLowerCase(),
        'orguid': selectedOrgUid.value.isNotEmpty ? selectedOrgUid.value : null,
      };

      final finalBanner = bannerUrl.value ?? imageUrl;
      if (finalBanner != null && finalBanner.isNotEmpty) {
        data['banner'] = finalBanner;
      }

      if (isEditing && eventId != null) {
        await supabase.from('events').update(data).eq('uid', eventId);
        Get.snackbar('Success', 'Event updated successfully');
      } else {
        await supabase.from('events').insert(data);
        Get.snackbar('Success', 'Event created successfully');
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
