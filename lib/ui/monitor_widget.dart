import 'package:flutter/material.dart';
import 'package:flutter_camera/api/gcs.dart';
import 'package:flutter_camera/model/camera_feed_status.dart';
import 'package:flutter_camera/model/photo_item.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:flutter_camera/providers/photo_processor_provider.dart';
import 'package:flutter_camera/ui/camera_widget.dart';
import 'package:flutter_camera/ui/inventory_item_widget.dart';
import 'package:flutter_camera/ui/location_selector_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class MonitorWidget extends ConsumerStatefulWidget {
  @override
  MonitorWidgetState createState() => MonitorWidgetState();
}

class MonitorWidgetState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  PhotoItem? _item;

  bool _isMicrophoneGranted = false;

  @override
  void initState() {
    super.initState();
    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _isMicrophoneGranted = status == PermissionStatus.granted;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() {
        _isMicrophoneGranted = true;
      });
    }
  }

  // Adjust these values as needed
  static const double locationSelectorHeight = 50.0;
  static const double statusBarHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    print('${DateTime.now()} Build debug widget');

    final lastInventoryItem = ref.watch(inventoryItemDetectedProvider);
    final isListening = canListen() && ref.watch(audioDescriptionProvider);

    if (lastInventoryItem != null &&
        lastInventoryItem.timestamp != _item?.timestamp) {
      _item = lastInventoryItem;

      print(
          '${DateTime.now()} Inventory widget, current item time ${_item!.creationTime}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('posting add item');

        ref
            .read(cameraFeedStateProvider.notifier)
            .setStatus(CameraFeedStatus.PAUSE);

        showPhotoItemDialog(context, _item!, timeoutSec: isListening ? 20 : 5);

        // Wait to get transcript?
        if (!isListening) {
          print("GOT ITEM no transcript");
          _item!.gcsUrl = GCSUploader.uploadImageEventually(_item!);
          ref.read(inventorySheetProvider.notifier).addItem(_item!);
        }
      });
    }

    return getContent(isListening: isListening);
  }

  bool canListen() {
    return true;
  }

  Widget getContent({bool isListening = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: locationSelectorHeight,
              child: LocationSelectorWidget(),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 300,
              child: CheckboxListTile(
                title: Text("Listen for descriptions"),
                value: isListening,
                onChanged: (bool? newValue) {
                  ref
                      .read(audioDescriptionProvider.notifier)
                      .setAudioDesc(newValue!);
                  if (newValue == true) {
                    _requestMicrophonePermission();
                  }
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              color: Colors.black12,
              height: 400,
              child: const CameraWidget(),
              //child: HLSVideoWidget(streamUrl: 'http://localhost:8083/play/hls/demo1/index.m3u8')
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

  void showPhotoItemDialog(BuildContext context, PhotoItem photoItem,
      {int timeoutSec = 5}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create the AlertDialog
        AlertDialog dialog = AlertDialog(
          title: Text('Found Item'),
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

        // Schedule the dialog to close after 10 seconds
        Future.delayed(Duration(seconds: timeoutSec), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ref
              .read(cameraFeedStateProvider.notifier)
              .setStatus(CameraFeedStatus.CAPTURE);
        });

        return dialog;
      },
    );
  }
}
