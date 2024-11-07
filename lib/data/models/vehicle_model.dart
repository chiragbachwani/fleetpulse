import 'dart:convert';

import 'package:fleet_pulse/data/models/location_model.dart';
import 'package:http/http.dart' as http;

class VehicleModel {
  final String id;
  final String plateNumber;
  final String type;
  final String? currentDriverId;
  final LocationModel? currentLocation;
  LocationModel? deliveryLocation;
  final String status; // 'available', 'on_delivery', 'maintenance'

  VehicleModel( {
    required this.deliveryLocation,
    required this.id,
    required this.plateNumber,
    required this.type,
    this.currentDriverId,
    this.currentLocation,
    required this.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    id: json['id'],
    plateNumber: json['plateNumber'],
    type: json['type'],
    currentDriverId: json['currentDriverId'],
    currentLocation: json['currentLocation'] != null 
      ? LocationModel.fromJson(json['currentLocation']) 
      : null,
    status: json['status'], 
    deliveryLocation: json['deliveryLocation'] != null 
      ? LocationModel.fromJson(json['deliveryLocation']) 
      : null,
  );


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
          administrativeArea = component['short_name'];  // State/Province abbreviation
        }
        if (component['types'].contains('neighborhood')) {
          neighborhood = component['long_name'];  // Neighborhood
        }
      }

      // Construct a concise, relevant address
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


  Map<String, dynamic> toJson() => {
    'id': id,
    'deliveryLocation': deliveryLocation?.toJson(),
    'plateNumber': plateNumber,
    'type': type,
    'currentDriverId': currentDriverId,
    'currentLocation': currentLocation?.toJson(),
    'status': status,
  };



  VehicleModel copyWith({
    String? id,
    String? plateNumber,
    List<LocationModel>? deliveryLocation,
  }) {
    return VehicleModel(
      type: type , 
           id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      deliveryLocation: deliveryLocation![0], status: status ,
    );

  
}}