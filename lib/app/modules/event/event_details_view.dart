import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventDetailsView extends StatelessWidget {
  const EventDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = Get.arguments;

    if (event == null || event is! Map<String, dynamic>) {
      _redirectToHome();
      return const _LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event['title'] ?? 'Event Details'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              Get.toNamed('/create-event', arguments: event); // ✅ Pass event to edit
            },
          )
        ],
      ),
      body: _EventDetailsBody(event: event),
    );
  }

  void _redirectToHome() {
    Future.microtask(() => Get.offAllNamed('/home'));
  }
}

class _EventDetailsBody extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventDetailsBody({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event['banner'] != null)
            _EventBanner(imageUrl: event['banner']),
          const SizedBox(height: 16),
          Text(
            event['title'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            event['description'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Location', value: event['location']),
          _InfoRow(label: 'Type', value: event['type']),
          _InfoRow(label: 'Start', value: _formatDate(event['datetimestart'])),
          _InfoRow(label: 'End', value: _formatDate(event['datetimeend'])),
          _InfoRow(label: 'Status', value: event['status']),
          if (event['tags'] != null && event['tags'] is List)
            _InfoRow(label: 'Tags', value: (event['tags'] as List).join(', ')),
        ],
      ),
    );
  }

  static String _formatDate(String? rawDateTime) {
    if (rawDateTime == null) return '';
    try {
      final dateTime = DateTime.parse(rawDateTime);
      return DateFormat('MMMM d, y, h:mm a').format(dateTime);
    } catch (_) {
      return rawDateTime ?? '';
    }
  }
}

class _EventBanner extends StatelessWidget {
  final String imageUrl;

  const _EventBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, softWrap: true),
          ),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
