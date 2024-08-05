import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/ui/audio_record_widget.dart';
//import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/debug_widget.dart';
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
        home: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.black,
              flexibleSpace: 
                const Text(
                  "  1PUL",
                  style: TextStyle(
                      fontFamily: 'AnaheimXB',
                      fontWeight: FontWeight.w800,
                      fontSize: 40,
                      color: Color.fromARGB(255, 192, 160, 247)),
                ),
              ),
          body: getCoolBackground(DebugWidget()),
          //body: getCoolBackground(RealTimeTranscription()),
        ));
  }
}
