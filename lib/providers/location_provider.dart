
// flutter pub run build_runner watch

import 'dart:ui';

import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:typed_data';

part 'location_provider.g.dart';

@Riverpod(keepAlive: true)
class InventoryItemDetected extends _$InventoryItemDetected {
  List<PhotoItem> items = [];

  @override
  Future<PhotoItem?> build() async {
    PhotoItem? item = items.isEmpty ? null : items.removeLast();
    return item;
  }  

  void onAutomationFieldsComplete(PhotoItem photoItem) {
    items.insert(0, photoItem);
  }

  void onHumanFieldsComplete(PhotoItem photoItem) {
    if (items.isNotEmpty) {
      state = AsyncData(items.last);
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

    print('Provider got locations ${_locations}');
    ref.watch(currentLocationProvider.notifier).setLocation(_locations[0]);
    return _locations;
  }

  Future<void> refreshLocations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => GoogleSheetsInventory().getLocations());
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