// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geminiModelHash() => r'c370faaec273be00da0edaa572ec2d405f9090fe';

/// See also [GeminiModel].
@ProviderFor(GeminiModel)
final geminiModelProvider = NotifierProvider<GeminiModel, String>.internal(
  GeminiModel.new,
  name: r'geminiModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$geminiModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GeminiModel = Notifier<String>;
String _$audioDescriptionHash() => r'e37f93c7c9fc39efdc4820c9096b3bf7e88b1863';

/// See also [AudioDescription].
@ProviderFor(AudioDescription)
final audioDescriptionProvider =
    NotifierProvider<AudioDescription, bool>.internal(
  AudioDescription.new,
  name: r'audioDescriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioDescriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AudioDescription = Notifier<bool>;
String _$inventoryItemDetectedHash() =>
    r'05590ba8bd51c8e27a6d8358db36f37dde297b80';

/// See also [InventoryItemDetected].
@ProviderFor(InventoryItemDetected)
final inventoryItemDetectedProvider =
    NotifierProvider<InventoryItemDetected, PhotoItem?>.internal(
  InventoryItemDetected.new,
  name: r'inventoryItemDetectedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryItemDetectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryItemDetected = Notifier<PhotoItem?>;
String _$inventorySheetHash() => r'b16578edd463d0a5df800cf30d7fcfe2347c1afd';

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
String _$locationListHash() => r'b414aea264e439bfc90565e08e73116cd902293a';

/// See also [LocationList].
@ProviderFor(LocationList)
final locationListProvider =
    NotifierProvider<LocationList, List<String>>.internal(
  LocationList.new,
  name: r'locationListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$locationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationList = Notifier<List<String>>;
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
