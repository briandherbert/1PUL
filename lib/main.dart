import 'package:flutter/material.dart';
//import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/camera_widget2.dart';
import 'package:flutter_camera/ui/test_inventory_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    // To install Riverpod, we need to add this widget above everything else.
    // This should not be inside "MyApp" but as direct parameter to "runApp".
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          //child: CameraWidget2(),
          child: TestInventoryWidget()
        ),
      ),
    );
  }
}
