import 'dart:convert';

import 'package:fleet_pulse/data/models/location_model.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ScheduleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  void fetchSchedules() {
    _firestore
        .collection('schedules')
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .listen((snapshot) {
      schedules.value = snapshot.docs
          .map((doc) => ScheduleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to fetch schedules: $error');
    });
  }

  Future<void> createSchedule(ScheduleModel schedule) async {
    try {
      isLoading.value = true;
      await _firestore.collection('schedules').add(schedule.toJson());
      Get.snackbar('Success', 'Schedule created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateScheduleStatus(
    String scheduleId, 
    String status, {
    List<String>? completedPickups,
    List<String>? completedDeliveries,
  }) async {
    try {

      final updates = <String, dynamic>{'status': status};
      if (completedPickups != null) {
        updates['completedPickups'] = completedPickups;
      }
      if (completedDeliveries != null) {
        updates['completedDeliveries'] = completedDeliveries;
      }
      await _firestore.collection('schedules').doc(scheduleId).update(updates);
      Get.snackbar('Success', 'Schedule status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update schedule status: $e');
    }
  }


  Future<String> getConciseAddress(double latitude, double longitude) async {
  final apiKey = 'YOUR API KEY HERE';
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

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
      }
    }
    return 'Location not found';
  } else {
    return 'Error retrieving location';
  }
}


Future<void> updateDriverAvailability(String driverId, bool isAvailable) async {
  try {

    final driverRef = _firestore.collection('drivers').doc(driverId);

    await driverRef.update({'isAvailable': isAvailable});
    
    Get.snackbar('Success', 'Driver availability updated successfully');
  } catch (e) {
    Get.snackbar('Error', 'Failed to update driver availability: $e');
  }
}


Future<void> updateDeliverylocation(String driverId,String vehicleid , LocationModel location) async {
  try {
    
    final vehicleRef = _firestore.collection('vehicles').doc(vehicleid);

    await vehicleRef.update({'deliveryLocation': location.toJson()});
    
    
  } catch (e) {
    Get.snackbar('Error', 'Failed to update driver availability: $e');
  }
}

}
