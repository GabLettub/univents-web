import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_controller.dart';
import 'home_controller.dart';
import 'dart:ui';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isCollapsed = true;
  String searchQuery = '';
  String selectedCategory = 'All';
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    homeController.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Get.find<LoginController>().supabase.auth.currentUser?.email ?? 'Admin';

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Row(
              children: [
                _buildSidebar(userEmail),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/addu_banner.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(color: Colors.black.withOpacity(0)),
            ),
          ),
        ],
      );

  Widget _buildSidebar(String userEmail) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isCollapsed ? 70 : 250,
        color: const Color(0xFF001F5B),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildProfile(userEmail),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    isCollapsed: isCollapsed,
                    onTap: () {},
                  ),
                  _SidebarItem(
                    icon: Icons.add_box_outlined,
                    label: 'Create Event',
                    isCollapsed: isCollapsed,
                    onTap: () => Get.toNamed('/create-event'),
                  ),
                  _SidebarItem(
                    icon: Icons.groups,
                    label: 'Organizations',
                    isCollapsed: isCollapsed,
                    onTap: () => Get.toNamed('/organizations'),
                  ),
                  _SidebarItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    isCollapsed: isCollapsed,
                    onTap: Get.find<LoginController>().logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildProfile(String userEmail) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blueAccent, size: 30),
            ),
            if (!isCollapsed) ...[
              const SizedBox(height: 10),
              const Text('Welcome Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
            ],
          ],
        ),
      );

  Widget _buildContent() => Expanded(
        child: Column(
          children: [
            _buildTopBar(),
            _buildEventsGrid(),
          ],
        ),
      );

  Widget _buildTopBar() => Container(
        height: 70,
        color: const Color(0xFF001F5B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search events...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              color: Colors.white,
              onSelected: (value) => setState(() => selectedCategory = value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'All', child: Text('All')),
                ...homeController.categories.map(
                  (category) => PopupMenuItem(
                    value: category,
                    child: Text(category.capitalizeFirst ?? category),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildEventsGrid() => Expanded(
        child: Obx(() {
          final events = homeController.getFilteredEvents(searchQuery, selectedCategory);
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () => Get.toNamed('/event-details', arguments: event),
                child: _EventCard(
                  title: event['title'] ?? '',
                  imageUrl: event['banner'] ?? '',
                  description: event['description'] ?? '',
                  visible: event['visible'],
                  event: event,
                ),
              );
            },
          );
        }),
      );
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: Colors.white),
        title: isCollapsed ? null : Text(label, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
      );
}

class _EventCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final bool? visible;
  final Map<String, dynamic> event;

  const _EventCard({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.event,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImage()),
          _buildTitle(),
          _buildDescription(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  visible == false ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blueGrey,
                ),
                tooltip: visible == false ? 'Unhide' : 'Hide',
                onPressed: () {
                  final controller = Get.find<HomeController>();
                  controller.toggleVisibility(event['uid'], !(visible ?? true));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF002358),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        description,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      final controller = Get.find<HomeController>();
      controller.deleteEventPermanently(event['uid']);
    }
  }
}
