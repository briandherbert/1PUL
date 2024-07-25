import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_camera/api/gcs.dart';
import 'package:flutter_camera/api/gemini.dart';
import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/bl/image_utils.dart' as img_utils;
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider.dart';

enum CaptureState { LOADING, CAPTURE, PAUSE, DIFF, AWAITING_BASELINE_RETURN }

final Map<PhotoState, MaterialColor> photoStateColors = {
  PhotoState.NORMAL: Colors.grey,
  PhotoState.DIFF: Colors.yellow,
  PhotoState.BASELINE: Colors.blue,
  PhotoState.INVENTORY: Colors.green,
  PhotoState.NOT_INVENTORY: Colors.purple,
  PhotoState.POST_INVENTORY_NOISE: Colors.pink,
};

class CameraWidget2 extends ConsumerStatefulWidget {
  const CameraWidget2({super.key});

  @override
  CameraWidgetState2 createState() => CameraWidgetState2();
}

class CameraWidgetState2 extends ConsumerState<CameraWidget2> {
  CameraController? _camerController;

  final BASELINE_IMAGE_REQ_FRAMES = 4;

  Timer? _timer;

  CaptureState _captureState = CaptureState.PAUSE;

  static const FRAME_INTERVAL_MS = 2000;

  String status = "initializing";
  String _aiResponse = "";

  final GoogleSheetsInventory _inventory = GoogleSheetsInventory();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _inventory.init();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _camerController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _camerController?.initialize();

    startCapture();
  }

  void setCaptureState(CaptureState newState) {
    debugPrint(
        'Setting capture state from ${_captureState.toString()} to ${newState.toString()}');
    setState(() {
      _captureState = newState;
    });
  }

  void startCapture() {
    setCaptureState(CaptureState.PAUSE);

    // Start capturing images every 500ms
    _timer = Timer.periodic(const Duration(milliseconds: FRAME_INTERVAL_MS),
        (timer) async {
      if (_captureState != CaptureState.PAUSE) {
        print('got new image');
        final bytes = await _captureImage(_camerController!);

        if (bytes != null) {
          ref.read(rawPhotoProcessorProvider.notifier).addRawPhoto(bytes);
        }
      }
    });
  }

  Future<Uint8List?> _captureImage(CameraController controller) async {
    Uint8List? bytes;

    if (controller.value.isInitialized) {
      try {
        final picture = await controller.takePicture();
        bytes = await picture.readAsBytes();
      } catch (e) {
        debugPrint('Error capturing image: $e');
      }
    }

    return bytes;
  }

  @override
  void dispose() {
    _camerController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _captureState == CaptureState.PAUSE;

    final processedPhotos = ref.watch(rawPhotoProcessorProvider);

    return Column(
      children: [
        Text(_captureState.toString()),
        Text("AI Response: $_aiResponse"),
        MaterialButton(
            child: Text(isPaused ? "Resume" : "Pause"),
            onPressed: () {
              setCaptureState(
                  isPaused ? CaptureState.CAPTURE : CaptureState.PAUSE);
            }),
        if (_camerController != null && _camerController!.value.isInitialized)
          Container(
              width: 300, height: 300, child: CameraPreview(_camerController!)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: processedPhotos.take(3).map((entry) {
            Uint8List bytes = entry.capturedBytes;

            return GestureDetector(
              onTap: () async {
                print("tapped image, uploading");
                final url = GCSUploader.uploadImage(
                    await img_utils.convertRawImageToJpeg(bytes));

                print("done upload");
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: photoStateColors[entry.photoState]!,
                      width: 4), // Set your desired border color and width
                ),
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
