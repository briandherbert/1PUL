import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/api/gcs.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter_camera/api/groq_whisper.dart';

class InventoryItemWidget extends ConsumerStatefulWidget {
  final PhotoItem photoItem;

  const InventoryItemWidget(this.photoItem, {super.key});

  @override
  InventoryItemWidgetState createState() => InventoryItemWidgetState();
}

class InventoryItemWidgetState extends ConsumerState<InventoryItemWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool playedChime = false;

  final int SECONDS_INTERVAL = 3;

  html.MediaRecorder? _mediaRecorder;
  List<Uint8List> _audioChunks = [];
  bool _isRecording = false;
  String _transcription = "";
  Timer? _timer;
  html.MediaStream? _stream;

  Future<void> _startRecording() async {
    try {
      _stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'audio': true});
      if (_stream != null) {
        _mediaRecorder =
            html.MediaRecorder(_stream!, {'mimeType': 'audio/webm'});
        _mediaRecorder!.addEventListener('dataavailable', _onDataAvailable);
        _mediaRecorder!.start();

        setState(() {
          _isRecording = true;
        });

        _timer = Timer(Duration(seconds: SECONDS_INTERVAL), () {
          _stopRecording();
        });
      } else {
        print('Failed to get media stream');
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void _onDataAvailable(html.Event event) {
    final blob = (event as html.BlobEvent).data!;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    reader.onLoadEnd.listen((event) {
      if (reader.result is Uint8List) {
        final data = reader.result as Uint8List;
        _audioChunks.add(data);

        Transcriber().getTranscription(_audioChunks, (result) {
          if (mounted) {
            setState(() {
              _transcription = result;

              Future.microtask(() async {
                print('GOT ITEM upload w transcript');
                widget.photoItem.humanDesc = _transcription;
                widget.photoItem.gcsUrl =
                    GCSUploader.uploadImageEventually(widget.photoItem);
                ref
                    .read(inventorySheetProvider.notifier)
                    .addItem(widget.photoItem);
              });
            });
          }
        });
      }
    });
  }

  void _stopRecording() {
    if (!_isRecording) return;

    _mediaRecorder?.stop();
    _timer?.cancel();
    _stream?.getTracks().forEach((track) => track.stop());

    setState(() {
      _isRecording = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Preload the audio file
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    await _audioPlayer.setSource(AssetSource('chime.mp3'));
    _audioPlayer.setVolume(0.5); // Set volume to a moderate level
  }

  @override
  void dispose() {
    if (mounted) {
      try {
        _audioPlayer.dispose();
      } catch (e) {
        print('error stopping audio player ' + e.toString());
      }

      try {
        _stopRecording();
      } catch (e) {
        print('error stopping recording ' + e.toString());
      }
    }

    super.dispose();
  }

  Future<void> _playChime() async {
    print("play chime");
    await _audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    final listen = ref.read(audioDescriptionProvider);

    if (!playedChime) {
      playedChime = true;
      // Schedule the chime to play after a short delay
      Future.delayed(const Duration(milliseconds: 50), () {
        _playChime();
      });

      if (listen) {
        Future.delayed(const Duration(milliseconds: 700), () {
          _startRecording();
        });
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Gemini Description",
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Text(
          widget.photoItem.geminiDesc!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 20,
        ),
        if (listen)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Human Description (speak to add)",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        if (listen)
          Text(
            _transcription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        SizedBox(
          width: 500,
          child: Image.memory(
            widget.photoItem.capturedBytes,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
