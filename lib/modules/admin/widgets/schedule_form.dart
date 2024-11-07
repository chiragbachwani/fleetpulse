import 'package:fleet_pulse/controllers/schedule_controller.dart';
import 'package:fleet_pulse/controllers/vehicle_controller.dart';
import 'package:fleet_pulse/data/models/driver_model.dart';
import 'package:fleet_pulse/data/models/location_model.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:fleet_pulse/data/models/vehicle_model.dart';
import 'package:fleet_pulse/modules/admin/views/location_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

var controller = Get.put(ScheduleController());
class ScheduleForm extends StatelessWidget {
  const ScheduleForm({Key? key}) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    
    final vehicleController = Get.put(VehicleController());
    final formKey = GlobalKey<FormState>();
    final selectedVehicle = Rxn<VehicleModel>();
    final selectedDriver = Rxn<DriverModel>();
    final pickupPoints = <LocationModel>[].obs;
    final deliveryPoints = <LocationModel>[].obs;
    final scheduledDate = Rx<DateTime>(DateTime.now());

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vehicle Selector
              Obx(() => DropdownButtonFormField<VehicleModel>(
                value: selectedVehicle.value,
                items: vehicleController.vehicles
                    .map((vehicle) => DropdownMenuItem(
                          value: vehicle,
                          child: Text('Vehicle ${vehicle.plateNumber}'),
                        ))
                    .toList(),
                onChanged: (value) { selectedVehicle.value = value;
                 if (value != null) {
                    vehicleController.fetchAvailableDrivers(value.id);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Select Vehicle',
                ),
                validator: (value) =>
                    value == null ? 'Please select a vehicle' : null,
              )),

              const SizedBox(height: 16),

              // Driver Selector (based on selected vehicle)
              Obx(() => DropdownButtonFormField<DriverModel>(
                value: selectedDriver.value,
                items: vehicleController.availableDrivers
                    .map((driver) => DropdownMenuItem(
                          value: driver,
                          child: Text(driver.name),
                        ))
                    .toList(), // Populate with available drivers
                onChanged: (value) => selectedDriver.value = value ,
                decoration: const InputDecoration(
                  labelText: 'Select Driver',
                ),
                validator: (value) =>
                   value == null ? 'Please select a driver' : null,
              )),

              const SizedBox(height: 16),

              // Pickup Points
              ListTile(
                title: const Text('Pickup Points'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showLocationPicker(context, pickupPoints),
                ),
              ),
              Obx(() => Column(
                    children: pickupPoints
                        .map((point) => ListTile(
                              title: Text(
                                  'Lat: ${point.latitude}, Lng: ${point.longitude}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => pickupPoints.remove(point),
                              ),
                            ))
                        .toList(),
                  )),

              // Delivery Points
              ListTile(
                title: const Text('Delivery Points'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showLocationPicker(context, deliveryPoints),
                ),
              ),
              Obx(() => Column(
                    children: deliveryPoints
                        .map((point) => ListTile(
                              title: Text(
                                  'Lat: ${point.latitude}, Lng: ${point.longitude}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deliveryPoints.remove(point),
                              ),
                            ))
                        .toList(),
                  )),

              const SizedBox(height: 16),

              // Schedule Date/Time Picker
              ListTile(
                title: const Text('Schedule Date/Time'),
                subtitle: Obx(() => Text(
                    '${scheduledDate.value.day}/${scheduledDate.value.month}/${scheduledDate.value.year} ${scheduledDate.value.hour}:${scheduledDate.value.minute}')),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDateTime(context, scheduledDate),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => _submitForm(
                                formKey,
                                selectedVehicle.value!,
                                selectedDriver.value?.id ?? '',
                                pickupPoints,
                                deliveryPoints,
                                scheduledDate.value,
                              ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text('Create Schedule'),
                    )),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLocationPicker(
      BuildContext context, RxList<LocationModel> points) async {
    // Implement location picker using MapBox
    // This is a simplified version - you'll need to implement the full map picker
    final location = await Get.to(() =>  LocationPickerView());
    if (location != null) {
      points.add(location);
    }
  }

   Future<void> _selectDateTime(BuildContext context, Rx<DateTime> date) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(date.value),
      );
      
      if (pickedTime != null) {
        date.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  void _submitForm(
    GlobalKey<FormState> formKey,
    VehicleModel vehicle,
    String driverId,
    RxList<LocationModel> pickupPoints,
    RxList<LocationModel> deliveryPoints,
    DateTime scheduledDate,
  ) async{
    if (formKey.currentState!.validate()) {
      final schedule = ScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: vehicle.id,
        driverId: driverId,
        pickupPoints: pickupPoints.toList(),
        deliveryPoints: deliveryPoints.toList(),
        scheduledStart: scheduledDate,
        status: 'pending',
        completedPickups: [],
        completedDeliveries: [],
      );
      
      controller.createSchedule(schedule);
      Get.back();

      await controller.updateDriverAvailability(driverId, false);
      await controller.updateDeliverylocation(driverId, vehicle.id, deliveryPoints[0]);
       
    }
  }
}