// flutter pub run build_runner watch

import 'package:flutter_camera/api/gemini.dart';
import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_provider.g.dart';

@Riverpod(keepAlive: true)
class GeminiModel extends _$GeminiModel {
  @override
  String build() => GEMINI_MODEL_PRO_EXP;
}

@Riverpod(keepAlive: true)
class AudioDescription extends _$AudioDescription {
  bool _audioDesc = false;

  @override
  bool build() => _audioDesc;

  void setAudioDesc(bool enabled) {
    state = enabled;
  }
}

@Riverpod(keepAlive: true)
class InventoryItemDetected extends _$InventoryItemDetected {
  List<PhotoItem> items = [];

  @override
  PhotoItem? build() {
    print('${DateTime.now()} Build inventory provider');

    PhotoItem? item = items.isEmpty ? null : items.removeLast();
    return item;
  }

  void onAutomationFieldsComplete(PhotoItem photoItem) {
    print("${DateTime.now()} item provider got photo ${photoItem.geminiDesc}");
    items = [photoItem, ...items];

    if (items.length >= 1) {
      state = items.removeLast();
      print('${DateTime.now()} set state inventory provider');

    }
  }

  void onHumanFieldsComplete(PhotoItem photoItem) {
    if (items.isNotEmpty) {
      state = items.last;
    }
  }
}

@Riverpod(keepAlive: true)
class InventoryItems extends _$InventoryItems {
  Future<List<InventoryItem>> build() async {
    return (await ref.watch(inventorySheetProvider.future)).readItems();
  }

}

@Riverpod(keepAlive: true)
class InventorySheet extends _$InventorySheet {
  final _inv = GoogleSheetsInventory();

  @override
  Future<GoogleSheetsInventory> build() async {
    await _inv.init();
    return _inv;
  }

  void addItem(PhotoItem photoItem) {
    print('adding item to sheet');
    _inv.addItem(InventoryItem.fromPhotoItem(photoItem));
  }
}

@Riverpod(keepAlive: true)
class LocationList extends _$LocationList {
  List<String> _locations = [];

  @override
  List<String> build() {
    // Initialize with an empty list
    _locations = [];
    // Trigger the fetch asynchronously
    fetchLocations();
    return _locations;
  }

  Future<void> fetchLocations() async {
    final inv = await ref.watch(inventorySheetProvider.future);

    print("location provider inventory value $inv");

    _locations = [...await inv.getLocations()];

    print('Provider got locations $_locations');
    state = _locations;
  }
}

@Riverpod(keepAlive: true)
class CurrentLocation extends _$CurrentLocation {
  @override
  String? build() => null;

  void setLocation(String location) {
    print('Set location $location');
    state = location;
  }

  void clearLocation() {
    state = null;
  }
}
