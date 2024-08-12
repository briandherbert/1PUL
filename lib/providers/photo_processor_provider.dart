// flutter pub run build_runner watch

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_camera/api/gcs.dart';
import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/camera_feed_status.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:typed_data';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/bl/image_utils.dart' as img_utils;
import 'dart:ui';
import 'package:flutter_camera/api/gemini.dart';

part 'photo_processor_provider.g.dart';

@Riverpod(keepAlive: true)
class ResolutionQuality extends _$ResolutionQuality {
  @override
  ResolutionPreset build() => ResolutionPreset.low;
}

@Riverpod(keepAlive: true)
class CameraFeedState extends _$CameraFeedState {
  @override
  CameraFeedStatus build() => CameraFeedStatus.LOADING;

  void setStatus(CameraFeedStatus status) {
    print('Set cam feed ${status.toString()}');
    state = status;
  }
}

@Riverpod(keepAlive: true)
class RawPhotoProcessor extends _$RawPhotoProcessor {
  final List<PhotoItem> _rawPhotoQueue = [];
  final List<PhotoItem> _processedPhotos = [];

  final List<PhotoItem> _baselineImages = [];
  final BASELINE_IMAGE_REQ_FRAMES = 4;
  final BASELINE_STREAK_LENGTH = 4;

  DateTime _lastInvTime = DateTime(1900);
  final FOUND_ITEM_COOLDOWN = Duration(seconds: 4);

  int _unchangedStreak = 0;

  bool _isProcessing = false;

  bool _ditchedLast = false;

  @override
  List<PhotoItem> build() {
    return _processedPhotos;
  }

  void addRawPhoto(Uint8List rawPhoto, String location) {
    print("Provider: Add raw photo, queue size ${_rawPhotoQueue.length}");
    // If queue is to big, throw away some frames
    if (_rawPhotoQueue.length > 4 && !_ditchedLast) {
      _rawPhotoQueue.removeLast();
      _ditchedLast = true;
    }

    final photoItem = PhotoItem(rawPhoto, location);

    _rawPhotoQueue.add(photoItem);
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
      print("Error processing photo ${e.toString()} ${st.toString()}");
      //state = [];
    } finally {
      _isProcessing = false;
      // Check if there are more photos to process
      _processNextPhoto();
    }
  }

  Future<PhotoItem> _processPhoto(PhotoItem photoItem) async {
    final Stopwatch stopwatch = Stopwatch();

    stopwatch.start();
    Image img = await img_utils.decodeImage(photoItem.capturedBytes);
    stopwatch.stop();
    print('Time to decode image: ${stopwatch.elapsedMilliseconds} ms');

    stopwatch.reset();
    stopwatch.start();
    photoItem.argbBytes = await img_utils.getPixelData(img);
    stopwatch.stop();
    print('Time to get pixel data: ${stopwatch.elapsedMilliseconds} ms');

    stopwatch.reset();
    stopwatch.start();
    //PhotoItem photoItem = PhotoItem(rawBytes, argbImg);
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
      photoState = PhotoState.INVENTORY;

      print('last inv time $_lastInvTime this photo ${photoItem.creationTime}');

      if (photoItem.creationTime.difference(_lastInvTime) <
          FOUND_ITEM_COOLDOWN) {
        photoState = PhotoState.POST_INVENTORY_NOISE;
      } else {
        stopwatch.reset();
        stopwatch.start();
        final jpegBytes = await photoItem.getJpegBytes();
        stopwatch.stop();
        print('Time to get jpeg bytes: ${stopwatch.elapsedMilliseconds} ms');
        stopwatch.reset();
        stopwatch.start();

        var geminiDesc = '';

        try {
          geminiDesc = await describeHeldObject(jpegBytes, modelName: ref.read(geminiModelProvider));
        } catch (e) {
          print('error $e');
        }

        photoItem.geminiDesc = geminiDesc;
        stopwatch.stop();

        print(
            'Time to call Gemini and describe object: ${stopwatch.elapsedMilliseconds} ms');

        if (geminiDesc.length < 10) {
          if (geminiDesc.toLowerCase().contains("none") || geminiDesc.length < 3) {
            photoState = PhotoState.NOT_INVENTORY;
          } else if (geminiDesc.toLowerCase().contains("blur")) {
            photoState = PhotoState.BLUR;
          }
        }

        if (photoState == PhotoState.INVENTORY) {
          print("got an item");
          _lastInvTime = photoItem.creationTime;
          ref
              .read(inventoryItemDetectedProvider.notifier)
              .onAutomationFieldsComplete(photoItem);
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
