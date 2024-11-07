import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_pulse/controllers/auth_controller.dart';
import 'package:fleet_pulse/modules/admin/views/admin_dashborad_view.dart';
import 'package:fleet_pulse/modules/auth/views/login_view.dart';
import 'package:fleet_pulse/utlis/const/firebase_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


// Function to request location permission and get the user's current location
Future<void> _getCurrentLocation() async {
  // Request location permission
  PermissionStatus permissionStatus = await Permission.location.request();

  // If permission is granted, fetch the user's location
  if (permissionStatus.isGranted) {
   
  } else {
    Get.snackbar('Permission Denied', 'Location permission is required to access your current location');
  }
}


class _SplashScreenState extends State<SplashScreen> {
  gotoNextScreen() {
    Future.delayed(const Duration(seconds: 4), () {
      // Get.to(() => const LoginScren());

      auth.authStateChanges().listen((User? user) {
        if (user == null && mounted) {
          Get.to(()=>const LoginScren());
        } else {
          Get.to(() => const AdminDashboardView());
        }
      });
    });
  }
// var controller = Get.put(AuthController());
  @override

  void initState() {
    _getCurrentLocation();
    gotoNextScreen();
    super.initState();
    // controller.uploadTestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/logo.png"))
        ],
      ),
    );
  }
}
