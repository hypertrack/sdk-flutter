# hypertrack_plugin

Plugin for HyperTrack SDK.

### Usage

To use this plugin, add `hypertrack_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
// Import package
import 'package:hypertrack_plugin/hypertrack.dart';

// Instantiate it
final sdk = await HyperTrack.initialize(my_publishable_key);


// Set device name
sdk.setDeviceName("Elvis");

// Get device id
final deviceId = await sdk.getDeviceId();
```

Visit https://hypertrack.com/ for more.
