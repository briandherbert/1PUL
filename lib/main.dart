import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_camera/globals.dart';
//import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/inventory_widget.dart';
import 'package:flutter_camera/ui/monitor_widget.dart';
import 'package:flutter_camera/ui/landing.dart';
import 'package:flutter_camera/ui/test_inventory_widget.dart';
import 'package:flutter_camera/ui/hls_viewer.dart';
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
    return MaterialApp(
        title: '1PUL',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black12,
          fontFamily: 'Anaheim',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 22),
            bodyMedium: TextStyle(fontSize: 16),
            labelLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        //home: getCoolScaffold(InventoryWidget()));
        home: getCoolScaffold(LandingWidget()));
  }
}

          //body: getCoolBackground(DebugWidget()),
          //body: TestInventoryWidget(),
          //body: HLSVideoWidget(streamUrl: 'http://localhost:8083/play/hls/demo1/index.m3u8'),
