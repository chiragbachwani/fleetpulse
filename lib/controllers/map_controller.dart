import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/location_model.dart';

class MapController extends GetxController {
  GoogleMapController? mapController;
  final RxBool isLoading = false.obs;
  final Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs; // Reactive set of markers
  final RxSet<Polyline> polylines = <Polyline>{}.obs; // Reactive set of polylines

  Future<void> initializeMap(GoogleMapController controller) async {
    mapController = controller;
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      final position = await Geolocator.getCurrentPosition();
      currentLocation.value = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }

      // Update marker for current location
      updateMarker(LatLng(position.latitude, position.longitude), 'current-location');
    } catch (e) {
      Get.snackbar('Error', 'Failed to get current location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateMarker(LatLng position, String markerId) {
    markers.clear(); // Clear previous markers if needed
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: markerId),
      ),
    );
  }

  void drawRoute(List<LatLng> coordinates) {
    polylines.clear(); // Clear previous polylines if needed
    polylines.add(
      Polyline(
        polylineId: PolylineId("route"),
        points: coordinates,
        color: const Color(0xFFFF0000),
        width: 3,
      ),
    );
  }


  
}
