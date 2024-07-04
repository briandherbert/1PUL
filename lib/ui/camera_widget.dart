import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_camera/bl/image_utils.dart' as img_utils;

class ResolutionStats {
  int captureTime = -1;
  int decodeTime = -1;
  List<int> widthHeight = [];

  @override
  String toString() {
    return 'ResolutionStats(captureTime: $captureTime ms, decodeTime: $decodeTime ms, widthHeight: ${widthHeight.isNotEmpty ? '${widthHeight[0]}x${widthHeight[1]}' : 'Unknown'})';
  }
}

enum CaptureState { LOADING, CAPTURE, PAUSE, DIFF }

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  final List<Uint8List> _capturedBytes = [];
  final List<Uint8List> _capturedImages = [];
  Timer? _timer;

  CaptureState _captureState = CaptureState.LOADING;

  String status = "initializing";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller?.initialize();

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
    setCaptureState(CaptureState.CAPTURE);

    // Start capturing images every 500ms
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      if (_captureState == CaptureState.CAPTURE) {
        final bytes = await _captureImage(_controller!);
        _addCapturedImage(bytes);
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

  void _addCapturedImage(Uint8List? bytes) async {
    if (bytes == null) return;

    Stopwatch sw = Stopwatch()..start();
    ui.Image image1 = await img_utils.decodeImage(bytes);

    print('decode time ${sw.elapsedMilliseconds}');

    Uint8List pixels1 = await img_utils.getPixelData(image1);

    print('pixel data time ${sw.elapsedMilliseconds}');

    print('got this many pix ${pixels1.length}');

    bool changed = _capturedImages.length > 1 &&
        img_utils.detectMovement(_capturedImages[0], _capturedImages[1]);
    print('changed? $changed');

    setState(() {
      _capturedBytes.insert(0, bytes);
      _capturedImages.insert(0, pixels1);
      if (_capturedImages.length > 3) {
        _capturedImages.removeLast();
        _capturedBytes.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _captureState == CaptureState.PAUSE;

    return Column(
      children: [
        Text(_captureState.toString()),
        MaterialButton(
            child: Text(isPaused ? "Resume" : "Pause"),
            onPressed: () {
              setCaptureState(
                  isPaused ? CaptureState.CAPTURE : CaptureState.PAUSE);
            }),
        if (_controller != null && _controller!.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _capturedBytes.map((bytes) {
            return Container(
              width: 100,
              height: 100,
              child: Image.memory(bytes, fit: BoxFit.cover),
            );
          }).toList(),
        ),
      ],
    );
  }
}
