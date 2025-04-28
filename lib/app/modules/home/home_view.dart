import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/login_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final userEmail = controller.supabase.auth.currentUser?.email ?? 'Admin';

    return Scaffold(
      body: Stack(
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

          SafeArea(
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF001F5B),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search events',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        color: Colors.white,
                        onSelected: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'All', child: Text('All')),
                          const PopupMenuItem(value: 'Academic', child: Text('Academic')),
                          const PopupMenuItem(value: 'Tech', child: Text('Tech')),
                          const PopupMenuItem(value: 'Law', child: Text('Law')),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    children: [
                      // Sidebar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCollapsed ? 70 : 250,
                        color: const Color(0xFF001F5B),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    isCollapsed = !isCollapsed;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              color: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              width: double.infinity,
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
                                    Text(
                                      userEmail,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
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
                                    icon: Icons.logout,
                                    label: 'Logout',
                                    isCollapsed: isCollapsed,
                                    onTap: controller.logout,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _EventList(
                          searchQuery: searchQuery,
                          selectedCategory: selectedCategory,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.isCollapsed, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: isCollapsed ? null : Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class _EventList extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;

  const _EventList({required this.searchQuery, required this.selectedCategory, super.key});

  final List<Map<String, String>> events = const [
    { 'title': 'Blue Vote', 'image': 'https://nbtooqanjpuitygixrmc.supabase.co/storage/v1/object/public/images//BLUEVOTEEVENT.jpg', 'category': 'Academic' },
    { 'title': 'IT Week 2025', 'image': 'https://nbtooqanjpuitygixrmc.supabase.co/storage/v1/object/public/images//IT%20Week%20pic.png', 'category': 'Tech' },
    { 'title': 'Mock Trials', 'image': 'https://nbtooqanjpuitygixrmc.supabase.co/storage/v1/object/public/images//MOCKTRIALEVENT.jpg', 'category': 'Law' },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredEvents = events.where((event) {
      final matchesSearch = event['title']!.toLowerCase().contains(searchQuery);
      final matchesCategory = selectedCategory == 'All' || event['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Center(
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return _EventCard(title: event['title'] ?? '', imageUrl: event['image'] ?? '');
          },
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _EventCard({required this.title, required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 300,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002358),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
