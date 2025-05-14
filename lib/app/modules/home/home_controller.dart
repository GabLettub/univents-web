import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  RxSet<String> categories = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await supabase
        .from('events')
        .select('uid, banner, title, description, location, type, tags, datetimestart, datetimeend, status');

    if (response != null) {
      events.assignAll(List<Map<String, dynamic>>.from(response));

      categories.clear();
      for (var event in events) {
        if (event['type'] != null) {
          categories.add(event['type']);
        }
      }
    }
  }

  List<Map<String, dynamic>> getFilteredEvents(String searchQuery, String selectedCategory) {
    return events.where((event) {
      final title = event['title']?.toString().toLowerCase() ?? '';
      final type = event['type']?.toString() ?? '';

      final matchesSearch = title.contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || type == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> deleteEventPermanently(String uid) async {
    try {
      await supabase.from('events').delete().eq('uid', uid);
      Get.snackbar('Deleted', 'Event has been permanently deleted.');
      await fetchEvents();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: $e');
    }
  }
}
