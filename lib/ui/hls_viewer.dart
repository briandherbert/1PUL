//
// Capture from a security cam like Wyze.
// If you have an RTSC stream, convert it to HLSLL with
// https://github.com/deepch/RTSPtoHLSLL
// While this works, and latency isn't an issue for passive security cams,
// it's killer on the single web thread. 
//

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/model/camera_feed_status.dart';
import 'package:flutter_camera/providers/photo_processor_provider.dart';
import 'package:flutter_camera/ui/location_selector_widget.dart';
import 'package:flutter_camera/ui/monitor_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import 'dart:js' as js;

class HLSVideoWidget extends ConsumerStatefulWidget {
  final String streamUrl;

  HLSVideoWidget({required this.streamUrl});

  @override
  _HLSVideoWidgetState createState() => _HLSVideoWidgetState();
}

class _HLSVideoWidgetState extends MonitorWidgetState<HLSVideoWidget> {
  late html.VideoElement _videoElement;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..controls = true;

    // Register the video element as a view
    ui_web.platformViewRegistry.registerViewFactory(
      'videoElement',
      (int viewId) => _videoElement,
    );

    // Load hls.js and initialize the video player
    _initializeHls();
  }

  void _initializeHls() {
    final streamUrl = widget.streamUrl.length > 5 ? widget.streamUrl : DEFAULT_HLS_STREAM;
    print("hls init with ${streamUrl}");
    final script = html.ScriptElement()
      ..src = 'https://cdn.jsdelivr.net/npm/hls.js@latest'
      ..type = 'application/javascript';
    script.onLoad.listen((event) {
      js.context.callMethod('initializeHls', [_videoElement, streamUrl]);
    });
    html.document.body!.append(script);
  }

  void startCapture() {

    if (_timer != null) {
      var isPaused = ref.watch(cameraFeedStateProvider) == CameraFeedStatus.PAUSE;
      ref.read(cameraFeedStateProvider.notifier).setStatus(
          isPaused ? CameraFeedStatus.CAPTURE : CameraFeedStatus.PAUSE);
          return;
    } else {
      ref.read(cameraFeedStateProvider.notifier).setStatus(CameraFeedStatus.CAPTURE);
    }

    // Start capturing images every 500ms
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      final captureStatus = ref.read(cameraFeedStateProvider);
      if (captureStatus == CameraFeedStatus.CAPTURE) {
        print('got new image');
        _captureFrame();
      }
    });
  }

  void _captureFrame() async {
    print("capture HLS frame");
    final canvas = html.CanvasElement(
        width: _videoElement.videoWidth, height: _videoElement.videoHeight);
    final context = canvas.context2D;
    context.drawImage(_videoElement, 0, 0);
    final blob = await canvas.toBlob('image/jpeg');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob!);
    reader.onLoadEnd.listen((event) {
      final bytes = reader.result as Uint8List;

      ref.read(rawPhotoProcessorProvider.notifier).addRawPhoto(bytes, 'Lab');
      //final image = img.decodeImage(bytes)!;
      // Do something with the image, e.g., save or display it
    });
  }

   @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  } 

  @override
  bool canListen() {
    return false;
  }

  @override
  Widget getContent({bool isListening = false}) {
    return Column(
      children: [
        LocationSelectorWidget(),
        const SizedBox(
          height: 300,
          child: HtmlElementView(viewType: 'videoElement'),
        ),
        const SizedBox(height: 10,),
        ElevatedButton(
          onPressed: startCapture,
          child: Text(ref.watch(cameraFeedStateProvider) == CameraFeedStatus.CAPTURE ? "PAUSE" : "CAPTURE"),
        ),
      ],
    );
  }
}

// JavaScript code to initialize hls.js
// Place this in a file named `assets/hls_initializer.js`
/*
function initializeHls(videoElement, streamUrl) {
  if (Hls.isSupported()) {
    var hls = new Hls();
    hls.loadSource(streamUrl);
    hls.attachMedia(videoElement);
    hls.on(Hls.Events.MANIFEST_PARSED, function () {
      videoElement.play();
    });
  } else if (videoElement.canPlayType('application/vnd.apple.mpegurl')) {
    videoElement.src = streamUrl;
    videoElement.addEventListener('loadedmetadata', function () {
      videoElement.play();
    });
  }
}
*/

