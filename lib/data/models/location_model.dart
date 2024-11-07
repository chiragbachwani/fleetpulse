class LocationModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    latitude: json['latitude'],
    longitude: json['longitude'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };
}
