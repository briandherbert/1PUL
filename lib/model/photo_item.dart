import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_camera/bl/image_utils.dart' as img_utils;
import 'package:intl/intl.dart';

enum PhotoState { NORMAL, BASELINE, DIFF, INVENTORY, BLUR, NOT_INVENTORY, POST_INVENTORY_NOISE }

class PhotoItem {
  final Uint8List capturedBytes;
  final String location;

  Uint8List? argbBytes;
  Uint8List? _jpegBytes;
  String? geminiDesc;
  String? humanDesc;
  String? gcsUrl;
  final DateTime timestamp;  // New field for timestamp

  PhotoState photoState = PhotoState.BASELINE;

  PhotoItem(
    this.capturedBytes, 
    this.location, {
    this.photoState = PhotoState.BASELINE,
  }) : 
    timestamp = DateTime.now();

  // Getter for the timestamp
  DateTime get creationTime => timestamp;

  bool isDifferent(PhotoItem other) {
    return img_utils.areImagesDifferent(argbBytes, other.argbBytes);
  }

  Future<Uint8List> getJpegBytes() async {
    _jpegBytes ??= await img_utils.convertRawImageToJpeg(capturedBytes, location);

    return _jpegBytes!;
  }

  // Optional: Format the timestamp as a string
  String get formattedTimestamp => DateFormat('yyyy_MM_dd_HH_mm_ss').format(timestamp);
}