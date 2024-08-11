import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/ui/inventory_widget.dart';

const FRAME_INTERVAL_MS = 600;
const REZ = ResolutionPreset.low;

const THEME_COLOR = Color.fromARGB(255, 192, 160, 247);

const DEFAULT_HLS_STREAM = 'http://localhost:8083/play/hls/demo1/index.m3u8';

String? getGcsImageUrl({PhotoItem? photoItem, String? inventoryItemId}) {
  String? timestamp;
  if (photoItem != null) {
    timestamp = 'image_${photoItem.formattedTimestamp}.jpeg';
  } else if (inventoryItemId != null) {
    timestamp = inventoryItemId;
  } else {
    return null;
  }

  return 'https://storage.googleapis.com/organizer_photos/image_$timestamp.jpeg';
}

Widget getCoolBackground(Widget widget) {
  return Material(
    child: Container(
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
    ),
  );
}

Widget getCoolScaffold(Widget widget) {
  return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        flexibleSpace: const Text(
          "    1PUL",
          style: TextStyle(
              fontFamily: 'AnaheimXB',
              fontWeight: FontWeight.w800,
              fontSize: 40,
              color: THEME_COLOR),
        ),
        iconTheme: const IconThemeData(
          color: THEME_COLOR, // Set the color of the back button (and other icons)
        ),
      ),
      body: getCoolBackground(widget));
}
