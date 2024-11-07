import 'package:fleet_pulse/controllers/schedule_controller.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateProgressForm extends StatelessWidget {
  final ScheduleModel schedule;

  const UpdateProgressForm({
    Key? key,
    required this.schedule,
  }) : super(key: key);

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
    final scheduleController = Get.find<ScheduleController>();
    final completedPickups = RxList<String>.from(schedule.completedPickups);
    final completedDeliveries = RxList<String>.from(schedule.completedDeliveries);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pickup Points'),
          ...List.generate(schedule.pickupPoints.length, (index) {
            final point = schedule.pickupPoints[index];
            final id = 'pickup_$index';

            return FutureBuilder<String>(
              future: getConciseAddress(point.latitude, point.longitude),
              builder: (context, snapshot) {
                String subtitleText = snapshot.connectionState == ConnectionState.waiting
                    ? 'Loading location...'
                    : snapshot.data ?? 'Location not available';

                return Obx(() => CheckboxListTile(
                      value: completedPickups.contains(id),
                      onChanged: (value) {
                        if (value ?? false) {
                          completedPickups.add(id);
                        } else {
                          completedPickups.remove(id);
                        }
                      },
                      title: Text('Pickup Point ${index + 1}'),
                      subtitle: Text(subtitleText),
                    ));
              },
            );
          }),
          const Divider(),
          const Text('Delivery Points'),
          ...List.generate(schedule.deliveryPoints.length, (index) {
            final point = schedule.deliveryPoints[index];
            final id = 'delivery_$index';

            return FutureBuilder<String>(
              future: getConciseAddress(point.latitude, point.longitude),
              builder: (context, snapshot) {
                String subtitleText = snapshot.connectionState == ConnectionState.waiting
                    ? 'Loading location...'
                    : snapshot.data ?? 'Location not available';

                return Obx(() => CheckboxListTile(
                      value: completedDeliveries.contains(id),
                      onChanged: (value) {
                        if (value ?? false) {
                          completedDeliveries.add(id);
                        } else {
                          completedDeliveries.remove(id);
                        }
                      },
                      title: Text('Delivery Point ${index + 1}'),
                      subtitle: Text(subtitleText),
                    ));
              },
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final allPickupsCompleted = completedPickups.length == schedule.pickupPoints.length;
                  final allDeliveriesCompleted = completedDeliveries.length == schedule.deliveryPoints.length;

                  final newStatus = allPickupsCompleted && allDeliveriesCompleted
                      ? 'completed'
                      : 'in_progress';

                  scheduleController.updateScheduleStatus(
                    schedule.id,
                    newStatus,
                    completedPickups: completedPickups.toList(),
                    completedDeliveries: completedDeliveries.toList(),
                  );  

                  scheduleController.updateDriverAvailability(schedule.driverId, true);


                  Get.back();
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
