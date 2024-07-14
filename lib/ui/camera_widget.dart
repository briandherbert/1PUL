import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_camera/api/gemini.dart';
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

///
/// What does capture mean? How do we differentiate movement that was showing something?
/// Baseline -> Diff (can become baseline) -> Human -> Recognized Object (await baseline or no human) -> Baseline
///
///
enum CaptureState {
  LOADING,
  CAPTURE,
  PAUSE,
  DIFF,
  AWAITING_BASELINE_RETURN
}

enum PhotoState {
  NORMAL,
  BASELINE,
  DIFF,
  INVENTORY
}

final Map<PhotoState, MaterialColor> photoStateColors = {
  PhotoState.NORMAL: Colors.grey,
  PhotoState.DIFF: Colors.yellow,
  PhotoState.BASELINE: Colors.blue,
};


class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  CameraController? _camerController;
  final List<Uint8List> _capturedBytes = [];
  final List<Uint8List> _capturedImages = [];
  final List<PhotoState> _photoStates = [];

  final List<Uint8List> _baselineImages = [];
  final BASELINE_IMAGE_REQ_FRAMES = 4;

  TextEditingController _promptTextController = TextEditingController();

  Timer? _timer;

  CaptureState _captureState = CaptureState.PAUSE;

  int _unchangedStreak = 0;

  final BASELINE_STREAK_LENGTH = 4;
  static const FRAME_INTERVAL_MS = 2000;
  static const IMAGE_CACHE_SIZE = 20;

  String status = "initializing";
  String _aiResponse = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
    _timer = Timer.periodic(const Duration(milliseconds: FRAME_INTERVAL_MS), (timer) async {
      if (_captureState != CaptureState.PAUSE) {
        final bytes = await _captureImage(_camerController!);
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
    var photoState = PhotoState.NORMAL;

    Stopwatch sw = Stopwatch()..start();
    ui.Image image1 = await img_utils.decodeImage(bytes);

    print('decode time ${sw.elapsedMilliseconds}');

    Uint8List pixels1 = await img_utils.getPixelData(image1);

    print('pixel data time ${sw.elapsedMilliseconds}');

    print('got this many pix ${pixels1.length}');

    // Check against last 2 images
    bool changed = _isDifferentThanPrev(pixels1);

    print('changed? $changed');

    if (changed) {
      _unchangedStreak = 0;
      photoState = PhotoState.DIFF;

      _describeHeldObject(bytes, _capturedImages.length);
    } else {
      _unchangedStreak += 1;
      if (_unchangedStreak >= BASELINE_STREAK_LENGTH) {
        photoState = PhotoState.BASELINE; 
        if (_unchangedStreak == BASELINE_STREAK_LENGTH) _baselineImages.add(bytes);    
      }
    }

    _capturedBytes.insert(0, bytes);
    _capturedImages.insert(0, pixels1);
    _photoStates.insert(0, photoState);


    if (_capturedImages.length > IMAGE_CACHE_SIZE) {
      _capturedImages.removeLast();
      _capturedBytes.removeLast();
      _photoStates.removeLast();
    }

    setState(() {});
  }

  bool _isDifferentThanPrev(Uint8List bytes, {int pastCt = 2}) {
    for (int i = 0; i < _capturedImages.length && i < pastCt; i++) {
      if (img_utils.areImagesDifferent(bytes, _capturedImages[i])) {
        return true;
      }
    }
    return false;
  }

  bool _isBaselineImage(Uint8List bytes) {
    for (final img in _baselineImages) {
      if (img_utils.areImagesDifferent(bytes, img)) {
        return true;
      }
    }
    return false;
  }

  Future<String> _describeHeldObject(Uint8List bytes, int imageIdx) async {
    final prompt = "You are a robot image analyzer for inventory management. If there is clearly someone holding or carrying an object, describe the object, otherwise, output NONE.";
    final result = await _sendGeminiImg(bytes, prompt);
    print("Gemini response $result");

    if (!result.toLowerCase().contains("none") || result.length > 10) {
      _aiResponse = result;
      setCaptureState(CaptureState.PAUSE);
    }

    return result;
  }

  @override
  void dispose() {
    _camerController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendGeminiMsg(String prompt) async {
    String response =
        await askGemini(prompt); // Replace with your async function
    setState(() {
      _aiResponse = response;
    });
  }

  Future<String> _sendGeminiImg(Uint8List bytes, String prompt) async {
    final jpegBytes = await img_utils.convertRawImageToJpeg(bytes);
    String response = await sendGeminiImage(jpegBytes,
        prompt: prompt); // Replace with your async function
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _captureState == CaptureState.PAUSE;

    return Column(
      children: [
        Text(_captureState.toString()),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _promptTextController,
                  decoration: const InputDecoration(
                    hintText: 'Enter message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendGeminiMsg(_promptTextController.text);
                },
              ),
            ],
          ),
        ),
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
          children: _capturedBytes.asMap().entries.take(3).map((entry) {
            int index = entry.key;
            Uint8List bytes = entry.value;

            return GestureDetector(
              onTap: () async { 
                final response = await _sendGeminiImg(bytes, _promptTextController.text);
                setState(() {
                  _aiResponse = response;
                });
                },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: photoStateColors[_photoStates[index]]!, width: 2), // Set your desired border color and width
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
