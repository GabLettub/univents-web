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
                  icon: Icons.add_box_outlined,
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
              const Text(
                'Welcome Admin',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                userEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
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
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0, 
              child: GridView.builder(
                key: ValueKey(events.length), 
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
                  return _EventCard(
                    title: event['title'] ?? '',
                    imageUrl: event['banner'] ?? '',
                    description: event['description'] ?? '',
                    event: event,
                  );
                },
              ),
            ),
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


class _EventCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String description;
  final Map<String, dynamic> event;

  const _EventCard({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.event,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  static const double _defaultScale = 1.0;
  static const double _pressedScale = 1.03;
  static const Duration _animationDuration = Duration(milliseconds: 150);

  double _scale = _defaultScale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _updateScale(_pressedScale),
      onTapUp: (_) => _updateScale(_defaultScale),
      onTapCancel: () => _updateScale(_defaultScale),
      onTap: _navigateToDetails,
      child: AnimatedScale(
        scale: _scale,
        duration: _animationDuration,
        curve: Curves.easeOut,
        child: _buildCard(),
      ),
    );
  }

  void _updateScale(double scale) {
    setState(() {
      _scale = scale;
    });
  }

  void _navigateToDetails() {
    Get.toNamed('/event-details', arguments: widget.event);
  }

  Widget _buildCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          _buildTitle(),
          _buildDescription(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(
          widget.imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.title,
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
        widget.description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


