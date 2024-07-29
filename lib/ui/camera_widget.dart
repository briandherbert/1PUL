import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/camera_feed_status.dart';
import 'package:flutter_camera/providers/location_provider.dart';
import 'package:flutter_camera/providers/photo_processor_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraWidget extends ConsumerStatefulWidget {
  const CameraWidget({super.key});

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends ConsumerState<CameraWidget> {
  CameraController? _camerController;

  static const FRAME_INTERVAL_MS = 1000;

  final BASELINE_IMAGE_REQ_FRAMES = 4;

  Timer? _timer;

  String status = "initializing";

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

    ref.read(cameraFeedStateProvider.notifier).setStatus(CameraFeedStatus.PAUSE);
    startCapture();
  }

  void startCapture() {
    // Start capturing images every 500ms
    _timer = Timer.periodic(const Duration(milliseconds: FRAME_INTERVAL_MS),
        (timer) async {
      final captureStatus = ref.read(cameraFeedStateProvider);
      if (captureStatus == CameraFeedStatus.CAPTURE) {
        print('got new image');
        final bytes = await _captureImage(_camerController!);

        if (bytes != null) {
          ref
              .read(rawPhotoProcessorProvider.notifier)
              .addRawPhoto(bytes, ref.read(currentLocationProvider) ?? 'none');
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
    var isPaused = ref.watch(cameraFeedStateProvider) == CameraFeedStatus.PAUSE;

    if (_camerController != null && _camerController!.value.isInitialized) {
      return GestureDetector(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: isPaused ? Colors.green : Colors.red,
              width: 14,
            ),
          ),
          child: IgnorePointer(child: CameraPreview(_camerController!)),
        ),
        onTap: () {
          print('Clicked, change pause state $isPaused');

          ref.read(cameraFeedStateProvider.notifier).setStatus(
              isPaused ? CameraFeedStatus.CAPTURE : CameraFeedStatus.PAUSE);
        },
      );
    }

    return const Text('Loading...');
  }
}
