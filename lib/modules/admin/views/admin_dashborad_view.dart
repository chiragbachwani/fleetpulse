import 'package:fleet_pulse/controllers/auth_controller.dart';
import 'package:fleet_pulse/data/models/location_model.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:fleet_pulse/data/models/vehicle_model.dart';
import 'package:fleet_pulse/modules/admin/views/location_picker_view.dart';
import 'package:fleet_pulse/modules/admin/widgets/responsive_layout.dart';
import 'package:fleet_pulse/modules/admin/widgets/schedule_form.dart';
import 'package:fleet_pulse/modules/admin/widgets/schedule_list.dart';
import 'package:fleet_pulse/modules/admin/widgets/tracking_map.dart';
import 'package:fleet_pulse/modules/admin/widgets/vehicle_list.dart';
// import 'package:fleet_pulse/modules/admin/widgets/tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

  
class AdminDashboardView extends StatelessWidget {


  const AdminDashboardView({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    // Initialize the AuthController
    var authcontroller = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleetpulse Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authcontroller.signout(context);
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        desktop: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: VehicleList(),
                  ),
                  Expanded(
                    child: ScheduleList(),
                  ),
                ],
              ),
            ),
const Expanded(
              flex: 3,
              child: TrackingMap(),
            ),
          ],
        ),
        mobile: Column(
          children: [
            // Expanded(
            //   flex: 2,
            //   child: const TrackingMap(),
            // ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Vehicles'),
                        Tab(text: 'Schedules'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          VehicleList(),
                          ScheduleList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showScheduleForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ScheduleForm(),
    );
  }
}