import 'package:fleet_pulse/controllers/schedule_controller.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:fleet_pulse/modules/admin/widgets/update_progress_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Import for async/await
import 'package:http/http.dart' as http; // Add HTTP for API call
import 'dart:convert'; // For decoding JSON

class ScheduleList extends StatelessWidget {
  const ScheduleList({Key? key}) : super(key: key);

  Future<String> getConciseAddress(double latitude, double longitude) async {
    final apiKey = 'YOUR API KEY HERE';
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          String? locality;
          String? administrativeArea;
          String? neighborhood;

          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality')) {
              locality = component['long_name'];
            }
            if (component['types'].contains('administrative_area_level_1')) {
              administrativeArea = component['short_name'];
            }
            if (component['types'].contains('neighborhood')) {
              neighborhood = component['long_name'];
            }
          }

          if (neighborhood != null && locality != null) {
            return '$neighborhood, $locality';
          } else if (locality != null && administrativeArea != null) {
            return '$locality, $administrativeArea';
          } else if (locality != null) {
            return locality;
          } else {
            return 'Location details not available';
          }
        } else {
          return 'Location not found';
        }
      } else {
        return 'Error retrieving location';
      }
    } catch (e) {
      return 'Error retrieving location';
    }
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ScheduleController());
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Schedules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: controller.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = controller.schedules[index];
                  return ExpansionTile(
                    title: Text('Schedule ${schedule.id}'),
                    subtitle: Text(
                      'Status: ${schedule.status} - '
                      '${schedule.scheduledStart.toString().split('.')[0]}',
                    ),
                    children: [
                      ListTile(
                        title: const Text('Pickup Points'),
                        subtitle: FutureBuilder<List<String>>(
                          future: Future.wait(schedule.pickupPoints.map((point) =>
                              getConciseAddress(point.latitude, point.longitude))),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading pickup locations...');
                            } else if (snapshot.hasError) {
                              return const Text('Error loading pickup locations');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!
                                    .map((address) => Text(address))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Delivery Points'),
                        subtitle: FutureBuilder<List<String>>(
                          future: Future.wait(schedule.deliveryPoints.map((point) =>
                              getConciseAddress(point.latitude, point.longitude))),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading delivery locations...');
                            } else if (snapshot.hasError) {
                              return const Text('Error loading delivery locations');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: snapshot.data!
                                    .map((address) => Text(address))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ),
                      if (schedule.status != 'completed' &&
                          schedule.status != 'cancelled')
                        ButtonBar(
                          children: [
                            TextButton(
                              onPressed: () => controller.updateScheduleStatus(
                                schedule.id,
                                'cancelled',
                              ),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateScheduleProgress(schedule),
                              child: const Text('Update Progress'),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _updateScheduleProgress(ScheduleModel schedule) {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Progress'),
        content: UpdateProgressForm(schedule: schedule),
      ),
    );
  }
}
