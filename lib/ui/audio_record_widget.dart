import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_camera/api/groq_whisper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RealTimeTranscription extends ConsumerStatefulWidget {
  const RealTimeTranscription({super.key});

  @override
  RealTimeTranscriptionState createState() => RealTimeTranscriptionState();
}

class RealTimeTranscriptionState extends ConsumerState<RealTimeTranscription> {
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
            });
          }
        });
      }
    });
  }

  void _stopRecording() {
    _mediaRecorder?.stop();
    _timer?.cancel();
    _stream?.getTracks().forEach((track) => track.stop());

    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_transcription),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
