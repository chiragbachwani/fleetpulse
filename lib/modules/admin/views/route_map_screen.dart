import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fleet_pulse/data/models/location_model.dart';

class RouteMapScreen extends StatefulWidget {
  final LocationModel currentLocation;
  final LocationModel deliveryLocation;

  const RouteMapScreen({
    Key? key,
    required this.currentLocation,
    required this.deliveryLocation,
  }) : super(key: key);

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController mapController;
  final Set<Polyline> _polylines = {};
  String googleAPIKey = "YOUR API KEY HERE";

  @override
  void initState() {
    super.initState();
    _getRoutePolyline();
  }

  Future<void> _getRoutePolyline() async {
    // Define the base URL and request parameters
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.currentLocation.latitude},${widget.currentLocation.longitude}'
        '&destination=${widget.deliveryLocation.latitude},${widget.deliveryLocation.longitude}'
        '&key=$googleAPIKey';

    // Fetch the route data
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data["status"] == "OK") {
      // Decode the polyline points and add them to the map
      final points = _decodePolyline(data["routes"][0]["overview_polyline"]["points"]);
      _addDottedPolyline(points);
    } else {
      print("Error fetching directions: ${data["status"]}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _addDottedPolyline(List<LatLng> points) {
  setState(() {
    _polylines.add(
      Polyline(
        polylineId: PolylineId("dotted_route"),
        points: points,
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dot], // Use dot pattern
      ),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            
            markerId: const MarkerId('currentLocation'),
            position: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
            infoWindow: const InfoWindow(title: 'Driver Location'),
          ),
          Marker(
            markerId: const MarkerId('deliveryLocation'),
            position: LatLng(widget.deliveryLocation.latitude, widget.deliveryLocation.longitude),
            infoWindow: const InfoWindow(title: 'Delivery Location'),
          ),
        },
        polylines: _polylines,
      ),
    );
  }
}
