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
    // Simulate photo processing (replace with your actual processing logic)
    Image img = await img_utils.decodeImage(rawBytes);
    Uint8List argbImg = await img_utils.getPixelData(img);

    PhotoItem photoItem = PhotoItem(rawBytes, argbImg);

    PhotoState photoState = PhotoState.BASELINE;

    if (_isBaselineImage(photoItem)) {
    } else if (_isDifferentThanPrev(photoItem)) {
      _unchangedStreak = 0;
      photoState = PhotoState.DIFF;

      if (photoItem.creationTime.difference(_lastInvTime) <
          FOUND_ITEM_COOLDOWN) {
        photoState = PhotoState.POST_INVENTORY_NOISE;
      } else {
        // Call Gemini, see if we have an image
        final jpegBytes = await photoItem.getJpegBytes();
        final geminiDesc = await describeHeldObject(jpegBytes);
        photoItem.geminiDesc = geminiDesc;
        photoState = geminiDesc == null
            ? PhotoState.NOT_INVENTORY
            : PhotoState.INVENTORY;

        if (photoState == PhotoState.INVENTORY) {
          print("got an item");
          GCSUploader.uploadImageEventually(photoItem);
        }
      }
    } else {
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
