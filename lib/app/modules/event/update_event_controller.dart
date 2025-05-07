import 'dart:typed_data';  // Import for Uint8List
import 'dart:io';  // Import for File
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';  // For image picking

class UpdateEventController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Define controllers for form fields
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

  final bannerUrl = RxnString();  // To store the banner URL
  final bannerBytes = Rxn<Uint8List>();  // To store the banner bytes (image)

  final isLoading = false.obs;
  final isInitialized = false.obs;

  String? eventId;  // To store event ID

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();

    // Get the event data passed from EventDetailsView
    final event = Get.arguments;  // Get the event data from arguments
    if (event != null && event is Map<String, dynamic>) {
      loadEventData(event);  // Load event data if available
    } else {
      print("No event data found in arguments.");
    }
  }

  // Method to load event data into the controllers
  void loadEventData(Map<String, dynamic> event) {
    eventId = event['uid'];  // Set the eventId
    print("Loaded event ID: $eventId");  // Debugging: Check if eventId is correctly set

    // Initialize form fields with event data
    title.text = event['title'] ?? '';
    description.text = event['description'] ?? '';
    location.text = event['location'] ?? '';
    tags.text = (event['tags'] as List?)?.join(', ') ?? '';
    type.value = event['type'] ?? '';
    selectedOrgUid.value = event['orguid'] ?? '';
    status.value = event['status'] ?? 'pending';
    bannerUrl.value = event['banner'];
    datetimeStart.value = event['datetimestart'] != null
        ? DateTime.tryParse(event['datetimestart'])
        : null;
    datetimeEnd.value = event['datetimeend'] != null
        ? DateTime.tryParse(event['datetimeend'])
        : null;

    isInitialized.value = true;  // Mark data as initialized
  }

  // Fetch organizations for the dropdown
  Future<void> fetchOrganizations() async {
    try {
      final response = await supabase.from('organizations').select('uid, name');
      organizations.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizations: $e');
    }
  }

  // Method to validate if the input is a valid UUID
  bool isValidUUID(String id) {
    final uuidPattern =
        RegExp(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$');
    return uuidPattern.hasMatch(id);
  }

  // Method to update event in the database
  Future<void> updateEvent() async {
    if (eventId == null || eventId!.isEmpty || !isValidUUID(eventId!)) {
      Get.snackbar('Error', 'Event ID is missing or invalid');
      print("No valid eventId found");  // Debugging: Check if eventId is invalid
      return;
    }

    isLoading.value = true;  // Set loading to true to indicate the process is happening
    print("Updating event...");

    try {
      if (title.text.trim().isEmpty || type.value.trim().isEmpty) {
        Get.snackbar('Validation Error', 'Title and type are required');
        print("Validation error: Title and type are required");
        return;
      }

      String? imageUrl;

      if (bannerBytes.value != null) {
        final fileName = 'event-${DateTime.now().millisecondsSinceEpoch}.jpg';
        print("Uploading image: $fileName");

        // Upload the image to Supabase
        await supabase.storage.from('images').uploadBinary(
          fileName,
          bannerBytes.value!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        imageUrl = supabase.storage.from('images').getPublicUrl(fileName);
        print("Image uploaded, URL: $imageUrl");
      }

      // Get the current user UID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Collect the data to update, including the UID
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
        'uid': userId, // Add the UID here
      };

      final finalBanner = bannerUrl.value ?? imageUrl;
      if (finalBanner != null && finalBanner.isNotEmpty) {
        data['banner'] = finalBanner;
      }

      // Update event in the Supabase database, using 'uid' for the identifier
      final response = await supabase.from('events').update(data).eq('uid', eventId);
      print("Event updated, response: ${response.data}");

      // Show success message
      Get.snackbar('Success', 'Event updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // After updating, navigate back to the home page
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home', arguments: {'refresh': true});
    } catch (e) {
      // Show error message
      Get.snackbar('Error', 'Update failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Error during update: $e");  // Debugging
    } finally {
      isLoading.value = false;  // Set loading to false when the process is finished
      print("Update process finished.");
    }
  }

  // Method to pick banner image from the device
  Future<void> pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      bannerBytes.value = await picked.readAsBytes();
      bannerUrl.value = null;
    }
  }

  // Method to select banner image from Supabase storage
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
