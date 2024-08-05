import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

const FRAME_INTERVAL_MS = 600;
const REZ = ResolutionPreset.low;

Widget getCoolBackground(Widget widget) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 156, 205, 245),
          Color.fromARGB(255, 226, 178, 249)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: widget,
  );
}
