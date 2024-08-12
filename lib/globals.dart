import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/ui/inventory_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const FRAME_INTERVAL_MS = 800;
const REZ = ResolutionPreset.low;

const THEME_COLOR = Color.fromARGB(255, 192, 160, 247);

const DEFAULT_HLS_STREAM = 'http://localhost:8083/play/hls/demo1/index.m3u8';

const PROMPT_HELD_OBJECT = "You are a robot image analyzer for inventory management. If there is clearly someone holding or carrying an object, and the object is visible enough to describe, describe the object (and only the object), otherwise, output NONE. If the object appears blurry or obstructed, output BLUR.";

const PROMPT_INVENTORY_SEARCH = "Answer the query from this list of item descriptions. Return the most relevant descriptions EXACTLY VERBATIM (DO NOT ALTER DESCRIPTIONS), in the format ITEMS: \nDESCRIPTION_1\nDESCRIPTION_2\n\n If there are no relevant matches, say \"none\". Even slightly relevant is ok, think more about practical application than keywords. If you need to say anything else, say it before listing items. Item decscriptions: \n";

String? getGcsImageUrl({PhotoItem? photoItem, String? inventoryItemId}) {
  String? timestamp;
  if (photoItem != null) {
    timestamp = 'image_${photoItem.formattedTimestamp}.jpeg';
  } else if (inventoryItemId != null) {
    timestamp = inventoryItemId;
  } else {
    return null;
  }

  return '${getGCSPrefix()}image_$timestamp.jpeg';
}

String getGCSPrefix() {
  return dotenv.env['GCS_PREFIX']!;
  //return 'https://storage.googleapis.com/organizer_photos/';
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
