
import 'package:fleet_pulse/splashscreen.dart';
import 'package:fleet_pulse/utlis/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FleetTrackingApp());
}



class FleetTrackingApp extends StatelessWidget {
  
  const FleetTrackingApp({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Fleet Tracking App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
    );
  }
}


