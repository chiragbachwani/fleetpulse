import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:fleet_pulse/controllers/map_controller.dart';
import 'package:fleet_pulse/data/models/location_model.dart';

class LocationPickerView extends StatelessWidget {
  LocationPickerView({Key? key}) : super(key: key);

  final TextEditingController searchController = TextEditingController();
  final MapController controller = Get.put(MapController());
  final selectedLocation = Rxn<LocationModel>();
  final uuid = Uuid();
  String _sessionToken = Uuid().v4();
  final RxList<dynamic> _placesList = [].obs;

  // Function to fetch place suggestions from Google Places API
  void getSuggestion(String input) async {
    const String apiKey = 'YOUR API KEY HERE';
    final String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request = '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';
    
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      _placesList.value = jsonDecode(response.body)['predictions'];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          Obx(() => TextButton(
                onPressed: selectedLocation.value != null
                    ? () => Get.back(result: selectedLocation.value)
                    : null,
                child: const Text('Confirm'),
              )),
        ],
      ),
      body: Column(
        children: [
          // Search bar to input location
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search location...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  getSuggestion(value);
                } else {
                  _placesList.clear();
                }
              },
            ),
          ),
          
          // Displaying place suggestions
          Obx(() => _placesList.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _placesList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_placesList[index]['description']),
                        onTap: () async {
                          // Get location details from the selected suggestion
                          final placeId = _placesList[index]['place_id'];
                          final details = await fetchPlaceDetails(placeId);
                          if (details != null) {
                            final lat = details['geometry']['location']['lat'];
                            final lng = details['geometry']['location']['lng'];
                            selectedLocation.value = LocationModel(
                              latitude: lat,
                              longitude: lng,
                              timestamp: DateTime.now(),
                            );
                            
                            // Update map position
                            controller.markers.clear();
                            controller.markers.add(
                              Marker(
                                markerId: const MarkerId('selected-location'),
                                position: LatLng(lat, lng),
                              ),
                            );
                            final GoogleMapController mapController = controller.mapController!;
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(LatLng(lat, lng)),
                            );
                            _placesList.clear();
                            searchController.clear();
                          }
                        },
                      );
                    },
                  ),
                )
              : Container()),
          
          // Google Map display
          Expanded(
            flex: 2,
            child: Obx(() => GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  onMapCreated: (GoogleMapController mapController) {
                    controller.initializeMap(mapController);
                  },
                  onTap: (coordinates) {
                    selectedLocation.value = LocationModel(
                      latitude: coordinates.latitude,
                      longitude: coordinates.longitude,
                      timestamp: DateTime.now(),
                    );

                    // Clear markers and add new marker at tapped location
                    controller.markers.clear();
                    controller.markers.add(
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: LatLng(coordinates.latitude, coordinates.longitude),
                      ),
                    );
                  },
                  markers: controller.markers.toSet(),
                )),
          ),
        ],
      ),
    );
  }

  // Function to fetch place details (latitude and longitude) from Google Places API
  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    const String apiKey = 'YOUR API KEY HERE';
    final String request = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['result'];
    }
    return null;
  }
}
