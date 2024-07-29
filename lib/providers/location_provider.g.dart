// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryItemDetectedHash() =>
    r'104d1580737389f46b630f60cb8f5b341c02a449';

/// See also [InventoryItemDetected].
@ProviderFor(InventoryItemDetected)
final inventoryItemDetectedProvider =
    AsyncNotifierProvider<InventoryItemDetected, PhotoItem?>.internal(
  InventoryItemDetected.new,
  name: r'inventoryItemDetectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryItemDetectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryItemDetected = AsyncNotifier<PhotoItem?>;
String _$inventorySheetHash() => r'46884a9445f31b4f41ce9f3d751c7201b2a51493';

/// See also [InventorySheet].
@ProviderFor(InventorySheet)
final inventorySheetProvider =
    AsyncNotifierProvider<InventorySheet, GoogleSheetsInventory>.internal(
  InventorySheet.new,
  name: r'inventorySheetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventorySheetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventorySheet = AsyncNotifier<GoogleSheetsInventory>;
String _$locationListHash() => r'548a5abd638b2eca0b82ddfaf7bcf4cebeb8330a';

/// See also [LocationList].
@ProviderFor(LocationList)
final locationListProvider =
    AsyncNotifierProvider<LocationList, List<String>>.internal(
  LocationList.new,
  name: r'locationListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$locationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationList = AsyncNotifier<List<String>>;
String _$currentLocationHash() => r'f982ec98be70e66eec82d3a0f5cf2338fcad70a8';

/// See also [CurrentLocation].
@ProviderFor(CurrentLocation)
final currentLocationProvider =
    NotifierProvider<CurrentLocation, String?>.internal(
  CurrentLocation.new,
  name: r'currentLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentLocation = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
