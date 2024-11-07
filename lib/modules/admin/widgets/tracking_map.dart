import 'package:fleet_pulse/controllers/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMap extends GetView<MapController> {
  const TrackingMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Live Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Obx(() => GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(0, 0),
                        zoom: 2,
                      ),
                      onMapCreated: (GoogleMapController mapController) {
                        controller.initializeMap(mapController);
                      },
                      markers: controller.markers.toSet(),
                      polylines: controller.polylines.toSet(),
                    )),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: controller.getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
