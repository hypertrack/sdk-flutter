# hypertrack_plugin

Plugin for HyperTrack SDK that allows you instantly feed location data in the cloud.

![GitHub](https://img.shields.io/github/license/hypertrack/sdk-flutter.svg)
[![Pub Version](https://img.shields.io/pub/v/hypertrack_plugin?color=blueviolet)](https://pub.dev/packages/hypertrack_plugin)
[![iOS SDK](https://img.shields.io/badge/iOS%20SDK-4.7.0-brightgreen.svg)](https://cocoapods.org/pods/HyperTrack)
![Android SDK](https://img.shields.io/badge/Android%20SDK-4.12.0-brightgreen.svg)

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
