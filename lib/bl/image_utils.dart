import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

//img.Decoder? decoder;

Map<String, img.Decoder> locationToDecoder = {};

Future<Uint8List> convertRawImageToJpeg(Uint8List imgBytes, String location) async {
  // Decode the raw image bytes
  var decoder = locationToDecoder[location];
  if (decoder == null) {
    decoder = img.findDecoderForData(imgBytes);
    print('found decoder ${decoder}');
    locationToDecoder[location] = decoder!;
  }

  img.Image? image = decoder.decode(imgBytes, frame: 0);

  if (image == null) {
    throw Exception('Unable to decode image');
  }

  // Log the image height and width
  print('Image width: ${image.width}, height: ${image.height}');

  if (image.height > 1900) {
    print('scale down image');
    image = img.copyResize(
      image,
      width: image.width ~/ 2,
      height: image.height ~/ 2,
    );
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

bool areImagesDifferent(Uint8List? pixels1, Uint8List? pixels2,
    {int threshold = 50, double percentage = .15, int step = 10}) {
  if (pixels1 == null) {
    return pixels2 != null;
  } else if (pixels2 == null) {
    return true;
  }

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
