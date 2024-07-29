import 'package:flutter/material.dart';
import 'package:flutter_camera/providers/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryItemWidget extends ConsumerStatefulWidget {
  const InventoryItemWidget({super.key});

  @override
  InventoryItemWidgetState createState() => InventoryItemWidgetState();
}

class InventoryItemWidgetState extends ConsumerState<InventoryItemWidget> {
  @override
  Widget build(BuildContext context) {
    final _lastInventoryItem = ref.watch(inventoryItemDetectedProvider).value;

    return _lastInventoryItem == null
        ? Container(
            color: Colors.grey,
          )
        : Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.memory(
                    _lastInventoryItem!.capturedBytes,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _lastInventoryItem!.geminiDesc!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
  }
}
