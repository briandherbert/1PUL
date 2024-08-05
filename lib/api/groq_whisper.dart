
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

typedef StringCallback = void Function(String);


class Transcriber {

  void getTranscription(List<Uint8List> audioChunks, StringCallback callback) async {
    String _transcription = '';
    if (audioChunks.isEmpty) callback(_transcription);

    final blob = html.Blob(audioChunks, 'audio/webm');
    audioChunks.clear();

    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    reader.onLoadEnd.listen((event) async {
      final audioData = reader.result as Uint8List;

      _transcription = await transcribeGroq(audioData);
      callback(_transcription);
    });
  }

  Future<String> transcribeGroq(Uint8List audioData) async {
    String transcription = '';
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioData,
        filename: 'audio.webm',
        contentType: MediaType('audio', 'webm'),
      ));
      request.fields['model'] = 'whisper-large-v3';
      request.fields['response_format'] = 'json';

      // Add your API key here
      final API_KEY = dotenv.env["GROQ_WHIPSER"];
      request.headers['Authorization'] =
          'Bearer ${API_KEY}';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      print('response $data');

      if (response.statusCode == 200) {
        transcription = data['text'];
      } else {
        print('Error: ${response.statusCode}, ${data['error']}');
      }
    } catch (e) {
      print('Error sending audio chunks: $e');
    }

    return transcription;
  }
}