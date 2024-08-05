import 'package:flutter/material.dart';
import 'package:flutter_camera/providers/inventory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationSelectorWidget extends ConsumerWidget {
  const LocationSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationList = ref.watch(locationListProvider).value;

    if (locationList == null || locationList.isEmpty) {
      return const Text("Loading locations...");
    }

    final currentLocation = ref.watch(currentLocationProvider);

    print('build location select, current $currentLocation');

    return DropdownButton<String>(
      value: currentLocation,
      hint: const Text('Select Location'),
      items: locationList.map((String location) {
        return DropdownMenuItem<String>(
          value: location,
          child: Text(
              location,
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
