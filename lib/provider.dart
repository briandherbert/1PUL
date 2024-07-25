// flutter pub run build_runner watch.

import 'dart:ui';

import 'package:flutter_camera/api/gcs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:typed_data';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/bl/image_utils.dart' as img_utils;
import 'dart:ui';
import 'package:flutter_camera/api/gemini.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
class RawPhotoProcessor extends _$RawPhotoProcessor {
  final List<Uint8List> _rawPhotoQueue = [];
  final List<PhotoItem> _processedPhotos = [];

  final List<PhotoItem> _baselineImages = [];
  final BASELINE_IMAGE_REQ_FRAMES = 4;
  final BASELINE_STREAK_LENGTH = 4;

  DateTime _lastInvTime = DateTime(1900);
  final FOUND_ITEM_COOLDOWN = Duration(seconds: 1);

  int _unchangedStreak = 0;

  bool _isProcessing = false;

  @override
  List<PhotoItem> build() {
    return _processedPhotos;
  }

  void addRawPhoto(Uint8List rawPhoto) {
    print("Provider: Add raw photo, queue size ${_rawPhotoQueue.length}");

    _rawPhotoQueue.add(rawPhoto);
    _processNextPhoto();
  }

  Future<void> _processNextPhoto() async {
    if (_isProcessing || _rawPhotoQueue.isEmpty) return;

    _isProcessing = true;
    try {
      final processedPhoto = await _processPhoto(_rawPhotoQueue.removeLast());
      _processedPhotos.insert(0, processedPhoto);
      state = [..._processedPhotos];
    } catch (e, st) {
      state = [];
    } finally {
      _isProcessing = false;
      // Check if there are more photos to process
      _processNextPhoto();
    }
  }

  Future<PhotoItem> _processPhoto(Uint8List rawBytes) async {
    final Stopwatch stopwatch = Stopwatch();

    stopwatch.start();
    Image img = await img_utils.decodeImage(rawBytes);
    stopwatch.stop();
    print('Time to decode image: ${stopwatch.elapsedMilliseconds} ms');

    stopwatch.reset();
    stopwatch.start();
    Uint8List argbImg = await img_utils.getPixelData(img);
    stopwatch.stop();
    print('Time to get pixel data: ${stopwatch.elapsedMilliseconds} ms');

    stopwatch.reset();
    stopwatch.start();
    PhotoItem photoItem = PhotoItem(rawBytes, argbImg);
    stopwatch.stop();
    print('Time to create PhotoItem: ${stopwatch.elapsedMilliseconds} ms');

    PhotoState photoState = PhotoState.BASELINE;

    stopwatch.reset();
    stopwatch.start();
    if (_isBaselineImage(photoItem)) {
      // Optionally time this section if necessary
    } else if (_isDifferentThanPrev(photoItem)) {
      stopwatch.stop();
      print(
          'Time to check if different than previous: ${stopwatch.elapsedMilliseconds} ms');

      _unchangedStreak = 0;
      photoState = PhotoState.DIFF;

      if (photoItem.creationTime.difference(_lastInvTime) <
          FOUND_ITEM_COOLDOWN) {
        photoState = PhotoState.POST_INVENTORY_NOISE;
      } else {
        stopwatch.reset();
        stopwatch.start();
        final jpegBytes = await photoItem.getJpegBytes();
        stopwatch.stop();
        print(
            'Time to get jpeg bytes: ${stopwatch.elapsedMilliseconds} ms');
        stopwatch.reset();
        stopwatch.start();

        final geminiDesc = await describeHeldObject(jpegBytes);
        photoItem.geminiDesc = geminiDesc;
        stopwatch.stop();
        print(
            'Time to call Gemini and describe object: ${stopwatch.elapsedMilliseconds} ms');

        photoState = geminiDesc == null
            ? PhotoState.NOT_INVENTORY
            : PhotoState.INVENTORY;

        if (photoState == PhotoState.INVENTORY) {
          print("got an item");
          //GCSUploader.uploadImageEventually(photoItem);
        }
      }
    } else {
      stopwatch.stop();
      print(
          'Time to check if same as previous: ${stopwatch.elapsedMilliseconds} ms');

      _unchangedStreak += 1;
      if (_unchangedStreak >= BASELINE_STREAK_LENGTH) {
        photoState = PhotoState.BASELINE;
        if (_unchangedStreak == BASELINE_STREAK_LENGTH)
          _baselineImages.insert(0, photoItem);
      }
    }

    photoItem.photoState = photoState;
    return photoItem;
  }

  // Look back more than one to overcome gradual change
  bool _isDifferentThanPrev(PhotoItem item, {int pastCt = 2}) {
    for (int i = 0; i < _processedPhotos.length && i < pastCt; i++) {
      if (item.isDifferent(_processedPhotos[i])) {
        return true;
      }
    }
    return false;
  }

  bool _isBaselineImage(PhotoItem item) {
    for (final img in _baselineImages.take(3)) {
      if (!item.isDifferent(img)) {
        return true;
      }
    }
    return false;
  }
}
