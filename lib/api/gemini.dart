import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;


Future<String> sendGeminiImage(Uint8List imageBytes, {prompt="What's this"}) async {
  debugPrint('sending Gemini image w prompt $prompt');
  // Access your API key as an environment variable
  final apiKey = dotenv.env['GEMINI_KEY'];
  if (apiKey == null) {
    print('No API_KEY environment variable');
    return 'nada';
  }

  // Initialize the GenerativeModel
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  // Prepare the image part
  final imagePart = DataPart('image/jpeg', imageBytes);

  // Prepare the prompt
  final promptData = TextPart(prompt);

  // Generate the content
  final response = await model.generateContent([
    Content.multi([promptData, imagePart])
  ]);

  // Print the response text
  print(response.text);
  return response.text!;
}

  Future<String?> describeHeldObject(Uint8List jpegBytes) async {
    final prompt =
        "You are a robot image analyzer for inventory management. If there is clearly someone holding or carrying an object, and the object is visible enough to describe, describe the object, otherwise, output NONE.";
    final result = await sendGeminiImage(jpegBytes, prompt: prompt);
    print("Gemini response $result");

    if (!result.toLowerCase().contains("none") || result.length > 10) {
      return result;
    }

    return null;
  }


Future<String> askGemini(String prompt) async {
  debugPrint('asking gemini $prompt');
  // Access your API key as an environment variable (see "Set up your API key" above)
  final apiKey = dotenv.env['GEMINI_KEY'];
  //final apiKey = "AIzaSyAHhstTQsNXedbmklJX3xkC24mXBrcYL_o";
  debugPrint('api key $apiKey');
  if (apiKey == null) {
    print('No \$API_KEY environment variable');
    exit(1);
  }
  // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  print(response.text);
  return response.text!;
}

void geminiCompareImages() async {
  // Access your API key as an environment variable (see "Set up your API key" above)
  final apiKey = Platform.environment['API_KEY'];
  if (apiKey == null) {
    print('No \$API_KEY environment variable');
    exit(1);
  }
  // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final (firstImage, secondImage) = await (
    File('image0.jpg').readAsBytes(),
    File('image1.jpg').readAsBytes()
  ).wait;
  final prompt = TextPart("What's different between these pictures?");
  final imageParts = [
    DataPart('image/jpeg', firstImage),
    DataPart('image/jpeg', secondImage),
  ];
  final response = await model.generateContent([
    Content.multi([prompt, ...imageParts])
  ]);
  print(response.text);
}