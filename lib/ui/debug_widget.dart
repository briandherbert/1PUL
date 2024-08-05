import 'package:flutter/material.dart';
import 'package:flutter_camera/model/camera_feed_status.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:flutter_camera/providers/photo_processor_provider.dart';
import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/inventory_item_widget.dart';
import 'package:flutter_camera/ui/location_selector_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugWidget extends ConsumerStatefulWidget {
  @override
  DebugWidgetState createState() => DebugWidgetState();
}

class DebugWidgetState extends ConsumerState<DebugWidget> {
  PhotoItem? _item;

  // Adjust these values as needed
  static const double locationSelectorHeight = 50.0;
  static const double statusBarHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final lastInventoryItem = ref.watch(inventoryItemDetectedProvider);

    if (lastInventoryItem != null &&
        lastInventoryItem.timestamp != _item?.timestamp) {
      _item = lastInventoryItem;

      print('Inventory widget, current item time ${_item!.creationTime}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('posting add item');
        ref.read(inventorySheetProvider.notifier).addItem(_item!);

        ref
            .read(cameraFeedStateProvider.notifier)
            .setStatus(CameraFeedStatus.PAUSE);

        showPhotoItemDialog(context, _item!);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: locationSelectorHeight,
              child: LocationSelectorWidget(),
            ),
            Container(
              color: Colors.black12,
              height: 300,
              child: const CameraWidget(),
            ),
            getStatsWidget(),
            Expanded(
              child: Container(),
            )
          ],
        );
      },
    );
  }

  Widget getStatsWidget() {
    var isRecording =
        ref.watch(cameraFeedStateProvider) == CameraFeedStatus.CAPTURE;

    var resolutionQuality = ref.read(resolutionQualityProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRecording ? "Monitoring" : "Paused",
          style: TextStyle(
            color: isRecording ? Colors.redAccent : Colors.grey,
          ),
        ),
        const SizedBox(
          height: 10,
          width: 10,
        ),
        Text(
          " | Quality: ${resolutionQuality.toString().split('.')[1]}",
        ),
        Text(
          " | Model: ${ref.read(geminiModelProvider)}",
        ),
      ],
    );
  }

  void showPhotoItemDialog(BuildContext context, PhotoItem photoItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dialog Title'),
          content: InventoryItemWidget(photoItem),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
