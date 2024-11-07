class DriverModel {
  final String id;
  final String name;
  final bool isAvailable;
  final String? assignedVehicleId;

  DriverModel({
    required this.id,
    required this.name,
    required this.isAvailable,
    this.assignedVehicleId,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'],
        name: json['name'],
        isAvailable: json['isAvailable'],
        assignedVehicleId: json['assignedVehicleId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isAvailable': isAvailable,
        'assignedVehicleId': assignedVehicleId,
      };
}
