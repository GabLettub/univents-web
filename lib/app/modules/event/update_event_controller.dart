import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UpdateEventController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final tags = TextEditingController();

  final type = RxString('');
  final selectedOrgUid = RxString('');
  final organizations = <Map<String, dynamic>>[].obs;
  final status = RxString('pending');

  final datetimeStart = Rxn<DateTime>();
  final datetimeEnd = Rxn<DateTime>();

  final bannerUrl = RxnString();
  final bannerBytes = Rxn<Uint8List>();

  final isLoading = false.obs;
  final isInitialized = false.obs;

  String? eventId;

  @override
  void onInit() {
    super.onInit();

    final event = Get.arguments;
    print("Received event: $event");

    if (event != null && event is Map<String, dynamic>) {
      if (event['uid'] != null && event['uid'].toString().isNotEmpty) {
        loadEventData(event);  // Set selectedOrgUid early
        fetchOrganizations();  // Now dropdown has something to match with
      } else {
        print("No valid UID in event data.");
        Get.snackbar('Error', 'No valid event ID provided.');
      }
    } else {
      print("Invalid or missing Get.arguments.");
    }
  }

  void loadEventData(Map<String, dynamic> event) {
    eventId = event['uid'];
    print(" Loaded event UID: $eventId");

    title.text = event['title'] ?? '';
    description.text = event['description'] ?? '';
    location.text = event['location'] ?? '';
    tags.text = (event['tags'] as List?)?.join(', ') ?? '';
    type.value = event['type'] ?? '';
    selectedOrgUid.value = event['orguid']?.toString() ?? '';
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

  bool isValidUUID(String id) {
    final uuidPattern =
        RegExp(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$');
    return uuidPattern.hasMatch(id);
  }

  Future<void> updateEvent() async {
    if (eventId == null || eventId!.isEmpty || !isValidUUID(eventId!)) {
      Get.snackbar('Error', 'Invalid or missing event UID');
      print(" Invalid eventId: '$eventId'");
      return;
    }

    isLoading.value = true;
    print(" Updating event with UID: $eventId");

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
      };

      if (selectedOrgUid.value.isNotEmpty && isValidUUID(selectedOrgUid.value)) {
        data['orguid'] = selectedOrgUid.value;
      }

      final finalBanner = bannerUrl.value ?? imageUrl;
      if (finalBanner != null && finalBanner.isNotEmpty) {
        data['banner'] = finalBanner;
      }

      final response = await supabase
          .from('events')
          .update(data)
          .eq('uid', eventId)
          .select();

      print(" Update response: $response");

      Get.snackbar('Success', 'Event updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home', arguments: {'refresh': true});
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print(" Error during update: $e");
    } finally {
      isLoading.value = false;
      print(" Update process finished");
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
        bannerBytes.value = null;
        bannerUrl.value = url;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}

