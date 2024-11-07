import 'package:fleet_pulse/controllers/vehicle_controller.dart';
import 'package:fleet_pulse/data/models/vehicle_model.dart';
import 'package:fleet_pulse/modules/admin/views/route_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleList extends StatelessWidget {
  const VehicleList({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
     var controller = Get.put(VehicleController());
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Vehicles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                itemCount: controller.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = controller.vehicles[index];
                  return ListTile(
                    leading: Icon(
                      Icons.local_shipping,
                      color: vehicle.status == 'available' 
                        ? Colors.green 
                        : Colors.grey,
                    ),
                    title: Text('Vehicle ${vehicle.plateNumber}'),
                    subtitle: Text('Status: ${vehicle.status}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => _showVehicleDetails(context, vehicle),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetails(BuildContext context, VehicleModel vehicle) {
  final controller = Get.find<VehicleController>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Vehicle ${vehicle.plateNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${vehicle.type}'),
          Text('Status: ${vehicle.status}'),
          if (vehicle.currentDriverId != null)
            Text('Current Driver ID: ${vehicle.currentDriverId}'),

          // Fetch and display the concise address for the current location
          if (vehicle.currentLocation != null)
            FutureBuilder(
              future: controller.getConciseAddress(
                vehicle.currentLocation!.latitude,
                vehicle.currentLocation!.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading current location...');
                } else if (snapshot.hasData) {
                  return Text('Current Location: ${snapshot.data}');
                } else {
                  return const Text('Current Location: Unknown');
                }
              },
            ),

          // Fetch and display the concise address for the delivery location
          if (vehicle.deliveryLocation != null)
            FutureBuilder(
              future: controller.getConciseAddress(
                vehicle.deliveryLocation!.latitude,
                vehicle.deliveryLocation!.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading delivery location...');
                } else if (snapshot.hasData) {
                  return Text('Delivery Location: ${snapshot.data}');
                } else {
                  return const Text('Delivery Location: Unknown');
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
        if (vehicle.currentLocation != null && vehicle.deliveryLocation != null)
          TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => RouteMapScreen(
                currentLocation: vehicle.currentLocation!,
                deliveryLocation: vehicle.deliveryLocation!,
              ));
            },
            child: const Text('View Route'),
          ),
      ],
    ),
  );
}



}