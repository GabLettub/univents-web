import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_event_controller.dart';
import 'package:intl/intl.dart';

class UpdateEventView extends GetView<UpdateEventController> {
  const UpdateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: Obx(() {
        // Show loading indicator until data is initialized
        if (!controller.isInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _textField(controller.title, 'Title'),
              _textField(controller.description, 'Description'),
              _textField(controller.location, 'Location'),
              _dropdownType(),
              _textField(controller.tags, 'Tags (comma-separated)'),
              _organizationDropdown(),
              _datePicker('Start DateTime', controller.datetimeStart),
              _datePicker('End DateTime', controller.datetimeEnd),
              _dropdownStatus(),
              const SizedBox(height: 10),
              _bannerUpload(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  print("Button clicked, calling updateEvent...");
                  await controller.updateEvent();  // Await the update event method
                  if (controller.isLoading.value) {
                    print("Still loading, please wait...");
                    return;
                  }
                  print("Update process complete.");
                },
                child: const Text('Update Event'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _dropdownType() {
    final types = ['instruction', 'engagement', 'formation', 'academics'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.type.value.isEmpty ? null : controller.type.value,
            items: types
                .map((t) => DropdownMenuItem(value: t, child: Text(t.capitalizeFirst!)))
                .toList(),
            onChanged: (val) => controller.type.value = val ?? '',
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
          )),
    );
  }

  Widget _dropdownStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.status.value,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'done', child: Text('Done')),
              DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
            ],
            onChanged: (val) => controller.status.value = val ?? 'pending',
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          )),
    );
  }

  Widget _organizationDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedOrgUid.value.isEmpty ? null : controller.selectedOrgUid.value,
            items: controller.organizations
                .map((org) => DropdownMenuItem<String>(
                      value: org['uid'],
                      child: Text(org['name']),
                    ))
                .toList(),
            onChanged: (val) => controller.selectedOrgUid.value = val ?? '',
            decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()),
          )),
    );
  }

  Widget _datePicker(String label, Rxn<DateTime> dateRx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() => ListTile(
            title: Text(label),
            subtitle: Text(
              dateRx.value != null
                  ? DateFormat('yMMMd • h:mm a').format(dateRx.value!)
                  : 'No date selected',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: dateRx.value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(dateRx.value ?? DateTime.now()),
                );
                if (time != null) {
                  dateRx.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                }
              }
            },
          )),
    );
  }

  Widget _bannerUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banner Image'),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.bannerBytes.value != null) {
            return Image.memory(controller.bannerBytes.value!, height: 150);
          } else if (controller.bannerUrl.value != null) {
            return Image.network(controller.bannerUrl.value!, height: 150);
          } else {
            return const Text('No image selected');
          }
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: controller.pickBanner,
              child: const Text('Upload from PC'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: controller.selectFromSupabase,
              child: const Text('Choose from Bucket'),
            ),
          ],
        ),
      ],
    );
  }
}
