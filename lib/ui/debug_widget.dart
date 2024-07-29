import 'package:flutter/material.dart';
import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/location_selector_widget.dart';
import 'package:flutter_camera/ui/past_frames_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        LocationSelectorWidget(),
        const Row(
          children: [
            CameraWidget(), 
            Expanded(child: PastFramesWidget())
          ],
        ),
      ],
    );
  }

}