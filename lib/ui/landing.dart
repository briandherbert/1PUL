import 'package:flutter/material.dart';
import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/ui/hls_viewer.dart';
import 'package:flutter_camera/ui/monitor_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingWidget extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();
  static const btnHeight = 80.0;
  static const spacerHeight = 40.0;

  LandingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: btnHeight),
          SizedBox(
            width: 400,
            height: btnHeight,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Inventory'),
            ),
          ),
          const SizedBox(height: spacerHeight),
          SizedBox(
            width: 400,
            height: 80,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => getCoolScaffold(
                        MonitorWidget()), // Assuming MonitorWidget does not include a Scaffold
                  ),
                );
              },
              child: const Text('Monitor'),
            ),
          ),
          const SizedBox(height: spacerHeight),
          SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Security Cam HLS'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter URL',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Push HLSVideoWidget with the entered URL
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => getCoolScaffold(HLSVideoWidget(
                                streamUrl:
                                    _controller.text),
                          ),
                        ));
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
