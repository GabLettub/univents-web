import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  // Events fetched from Supabase
  RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;

  // Filter options (based on type)
  RxSet<String> categories = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await supabase
        .from('events')
        .select('uid, banner, title, description, location, type, tags');

    if (response != null) {
      events.assignAll(List<Map<String, dynamic>>.from(response));

      // Collect categories from event types
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
}
