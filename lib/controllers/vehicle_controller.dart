import 'dart:convert';

import 'package:fleet_pulse/data/models/driver_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/vehicle_model.dart';
import '../data/models/location_model.dart';
import 'package:http/http.dart' as http;

class VehicleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
  }

  void fetchVehicles() {
    _firestore.collection('vehicles').snapshots().listen((snapshot) {
      vehicles.value = snapshot.docs
          .map((doc) => VehicleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to fetch vehicles: $error');
    });
  }

  Future<void> updateVehicleLocation(String vehicleId, LocationModel location) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .update({'currentLocation': location.toJson()});
      Get.snackbar('Success', 'Vehicle location updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update vehicle location: $e');
    }
  }

  Future<void> assignDriver(String vehicleId, String driverId) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .update({'currentDriverId': driverId});
      Get.snackbar('Success', 'Driver assigned to vehicle');
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign driver: $e');
    }
  }


  final RxList<DriverModel> availableDrivers = <DriverModel>[].obs;


  Future<void> fetchAvailableDrivers(String vehicleId) async {
    try {
      availableDrivers.clear();
      
     
      final snapshot = await _firestore
          .collection('drivers')
          .where('isAvailable', isEqualTo: true)
          .get();

      availableDrivers.value = snapshot.docs
          .map((doc) => DriverModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch available drivers: $e');
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
          locality = component['long_name'];  // City
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

}
