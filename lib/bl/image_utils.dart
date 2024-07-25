import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

img.Decoder? decoder;

Future<Uint8List> convertRawImageToJpeg(Uint8List imgBytes) async {
  // Decode the raw image bytes
  if (decoder == null) {
    decoder = img.findDecoderForData(imgBytes);
    print('found decoder ${decoder}');
  }
  img.Image? image = decoder!.decode(imgBytes);

  if (image == null) {
    throw Exception('Unable to decode image');
  }

  // Encode the image to JPEG
  Uint8List jpegBytes = Uint8List.fromList(img.encodeJpg(image));
  return jpegBytes;
}

Future<ui.Image> decodeImage(Uint8List imgBytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(imgBytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

Future<Uint8List> getPixelData(ui.Image image) async {
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    throw Exception('Unable to retrieve pixel data');
  }
  return byteData.buffer.asUint8List();
}

bool areImagesDifferent(Uint8List pixels1, Uint8List pixels2,
    {int threshold = 50, double percentage = .15, int step = 10}) {
  int minLength =
      pixels1.length < pixels2.length ? pixels1.length : pixels2.length;

  int diffCount = 0;
  int totalComparisons = minLength ~/ step;

  for (int i = 0; i < minLength; i += step) {
    int diff = (pixels1[i] - pixels2[i]).abs();
    if (diff > threshold) {
      diffCount++;
    }
  }

  double diffPercentage = diffCount / totalComparisons;
  return diffPercentage > percentage;
}
