import 'package:fleet_pulse/data/models/location_model.dart';

class ScheduleModel {
  final String id;
  final String vehicleId;
  final String driverId;
  final List<LocationModel> pickupPoints;
  final List<LocationModel> deliveryPoints;
  final DateTime scheduledStart;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final List<String> completedPickups;
  final List<String> completedDeliveries;

  ScheduleModel({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.pickupPoints,
    required this.deliveryPoints,
    required this.scheduledStart,
    this.actualStart,
    this.actualEnd,
    required this.status,
    required this.completedPickups,
    required this.completedDeliveries,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    vehicleId: json['vehicleId'],
    driverId: json['driverId'],
    pickupPoints: (json['pickupPoints'] as List)
      .map((p) => LocationModel.fromJson(p))
      .toList(),
    deliveryPoints: (json['deliveryPoints'] as List)
      .map((p) => LocationModel.fromJson(p))
      .toList(),
    scheduledStart: DateTime.parse(json['scheduledStart']),
    actualStart: json['actualStart'] != null 
      ? DateTime.parse(json['actualStart'])
      : null,
    actualEnd: json['actualEnd'] != null 
      ? DateTime.parse(json['actualEnd'])
      : null,
    status: json['status'],
    completedPickups: List<String>.from(json['completedPickups']),
    completedDeliveries: List<String>.from(json['completedDeliveries']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'driverId': driverId,
    'pickupPoints': pickupPoints.map((p) => p.toJson()).toList(),
    'deliveryPoints': deliveryPoints.map((p) => p.toJson()).toList(),
    'scheduledStart': scheduledStart.toIso8601String(),
    'actualStart': actualStart?.toIso8601String(),
    'actualEnd': actualEnd?.toIso8601String(),
    'status': status,
    'completedPickups': completedPickups,
    'completedDeliveries': completedDeliveries,
  };
}