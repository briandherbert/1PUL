// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_processor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$rawPhotoProcessorHash() => r'3edb4bb6ceef3fe84551c722ce81a49be46a1bc4';

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
