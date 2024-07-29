import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_camera/providers/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationSelectorWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = ref.watch(currentLocationProvider);
    final locationList = ref.watch(locationListProvider).value;

    print('build location select, current $currentLocation');

    if (currentLocation == null || locationList == null || locationList.isEmpty) {
      return Text("Loading locations...");
    }

    return DropdownButton<String>(
      value: currentLocation,
      hint: Text('Select Location'),
      items: locationList!.map((String location) {
        return DropdownMenuItem<String>(
          value: location,
          child: Text(location),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          ref.watch(currentLocationProvider.notifier).setLocation(newValue);
        }
      },
    );
  }
}
