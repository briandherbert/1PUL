import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/providers/photo_processor_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Map<PhotoState, MaterialColor> photoStateColors = {
  PhotoState.NORMAL: Colors.grey,
  PhotoState.DIFF: Colors.yellow,
  PhotoState.BASELINE: Colors.blue,
  PhotoState.INVENTORY: Colors.green,
  PhotoState.NOT_INVENTORY: Colors.purple,
  PhotoState.POST_INVENTORY_NOISE: Colors.pink,
};

class PastFramesWidget extends ConsumerStatefulWidget {
  const PastFramesWidget({super.key});

  @override
  PastFramesWidgetState createState() => PastFramesWidgetState();
}

class PastFramesWidgetState extends ConsumerState<PastFramesWidget> {
  @override
  Widget build(BuildContext context) {
    final processedPhotos = ref.watch(rawPhotoProcessorProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: processedPhotos.take(3).map((entry) {
        Uint8List bytes = entry.capturedBytes;
  
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: photoStateColors[entry.photoState]!,
              width: 4,
            ),
          ),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      }).toList(),
    );
  }
}
