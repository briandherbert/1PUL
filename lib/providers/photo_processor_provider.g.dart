// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_processor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resolutionQualityHash() => r'56a45d5f5ad1fccee17b07c9556465c5a9a0be38';

/// See also [ResolutionQuality].
@ProviderFor(ResolutionQuality)
final resolutionQualityProvider =
    NotifierProvider<ResolutionQuality, ResolutionPreset>.internal(
  ResolutionQuality.new,
  name: r'resolutionQualityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resolutionQualityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ResolutionQuality = Notifier<ResolutionPreset>;
String _$cameraFeedStateHash() => r'ed4ee7e913f5c2b0a9d08c46d280d82bd9f8c24b';

/// See also [CameraFeedState].
@ProviderFor(CameraFeedState)
final cameraFeedStateProvider =
    NotifierProvider<CameraFeedState, CameraFeedStatus>.internal(
  CameraFeedState.new,
  name: r'cameraFeedStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraFeedStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CameraFeedState = Notifier<CameraFeedStatus>;
String _$rawPhotoProcessorHash() => r'1e8d0e7eabb3a595296afbb4ec4e80035e300c78';

/// See also [RawPhotoProcessor].
@ProviderFor(RawPhotoProcessor)
final rawPhotoProcessorProvider =
    NotifierProvider<RawPhotoProcessor, List<PhotoItem>>.internal(
  RawPhotoProcessor.new,
  name: r'rawPhotoProcessorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rawPhotoProcessorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RawPhotoProcessor = Notifier<List<PhotoItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
