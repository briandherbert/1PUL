// flutter pub run build_runner watch


import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_provider.g.dart';

@Riverpod(keepAlive: true)
class GeminiModel extends _$GeminiModel {
  final GEMINI_PRO_EXP = 'gemini-1.5-pro-exp-0801';
  final GEMINI_FLASH = 'gemini-1.5-flash';

  @override
  String build() => GEMINI_FLASH;
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
    PhotoItem? item = items.isEmpty ? null : items.removeLast();
    return item;
  }

  void onAutomationFieldsComplete(PhotoItem photoItem) {
    print("Inventory item provider got photo ${photoItem.geminiDesc}");
    items = [photoItem, ...items];

    if (items.length == 1) {
      state = items.removeLast();
    }
  }

  void onHumanFieldsComplete(PhotoItem photoItem) {
    if (items.isNotEmpty) {
      state = items.last;
    }
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
  Future<List<String>> build() async {
    final inv = await ref.watch(inventorySheetProvider.future);

    print("location provider inventory value $inv");

    _locations = [...await inv.getLocations()];

    print('Provider got locations $_locations');
    ref.watch(currentLocationProvider.notifier).setLocation(_locations[0]);
    return _locations;
  }

  Future<void> refreshLocations() async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => GoogleSheetsInventory().getLocations());
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
