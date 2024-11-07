import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:fleet_pulse/data/models/driver_model.dart';
import 'package:fleet_pulse/data/models/location_model.dart';
import 'package:fleet_pulse/data/models/schedue_model.dart';
import 'package:fleet_pulse/data/models/vehicle_model.dart';
import 'package:fleet_pulse/modules/auth/views/login_view.dart';
import 'package:fleet_pulse/utlis/const/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable properties
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  // Controllers for form input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Login method
  Future<UserCredential?> loginMethod(BuildContext context) async {
    UserCredential? userCredential;
    isLoading.value = true;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message ?? 'An error occurred during login');
    }

    return userCredential;
  }

  // Signup method
  Future<UserCredential?> signupMethod(
      {required String email, required String password, required String name, required String role, BuildContext? context}) async {
    UserCredential? userCredential;
    isLoading.value = true;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // If the user is successfully created, store their information in Firestore
      if (userCredential.user != null) {
        await storeUserData(
          password: password,
          userId: userCredential.user!.uid,
          email: email,
          name: name,

        );
      }

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message ?? 'An error occurred during signup');
    }

    return userCredential;
  }

  // Store user data method
Future<void> storeUserData({
  required String userId,
  required String email,
  required String name,
  required String password,
  // String? driverId,
}) async {
  try {
    // Hash the password
    var bytes = utf8.encode(password);
    var hashedPassword = sha256.convert(bytes).toString();

    UserModel newUser = UserModel(
      password: hashedPassword,
      id: userId,
      email: email,
      name: name,
      // driverId: driverId,
    );

    await _firestore.collection('User').doc(userId).set(newUser.toJson());
  } catch (e) {
    Get.snackbar('Error', 'Failed to store user data: ${e.toString()}');
  }
}

  // Sign-out method
  Future<void> signout(BuildContext context) async {
  try {
    await _auth.signOut();
    
    // Clear the entire stack and navigate to the login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScren()),
      (Route<dynamic> route) => false,  // This removes all previous routes
    );
  } catch (e) {
    Get.snackbar('Error', 'Failed to sign out: ${e.toString()}');
  }
}



//to upload test data in firestore
//   Future<void> uploadTestData() async {
//   final firestore = FirebaseFirestore.instance;

//   // Dummy data for Schedule
// final schedule = ScheduleModel(
//   id: 'schedule_4',
//   vehicleId: 'vehicle_4',
//   driverId: 'driver_4',
//   pickupPoints: [
//     LocationModel(latitude: 12.9716, longitude: 77.5946, timestamp: DateTime.now()),
//     LocationModel(latitude: 12.9350, longitude: 77.6240, timestamp: DateTime.now()),
//   ],
//   deliveryPoints: [
//     LocationModel(latitude: 13.0827, longitude: 80.2707, timestamp: DateTime.now()),
//     LocationModel(latitude: 13.0670, longitude: 80.2376, timestamp: DateTime.now()),
//   ],
//   scheduledStart: DateTime.now(),
//   actualStart: DateTime.now(),
//   actualEnd: DateTime.now().add(Duration(hours: 3)),
//   status: 'completed',
//   completedPickups: ['pickup1', 'pickup2'],
//   completedDeliveries: ['delivery1'],
// );




// final vehicle = VehicleModel(
//   id: 'vehicle_4',
//   plateNumber: 'MH12EF4567',
//   type: 'truck',
//   currentDriverId: 'driver_4',
//   currentLocation: LocationModel(latitude: 28.7041, longitude: 77.1025, timestamp: DateTime.now()),
//   status: 'maintenance',
// );




//  final driver = DriverModel(
//   id: "driver_4",
//   name: "Vikash",
//   isAvailable: false,
//   assignedVehicleId: "vehicle_4",
// );



    


//   // Upload Schedule data
//   await firestore.collection('schedules').doc(schedule.id).set(schedule.toJson());
  

//   await firestore.collection('drivers').doc(driver.id).set(driver.toJson());

//   // Upload Vehicle data
//   await firestore.collection('vehicles').doc(vehicle.id).set(vehicle.toJson());

//   print('Data uploaded successfully!');
// }
}
