import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/hypertrack.dart';

import '../hypertrack_platform_interface.dart';

/// A subclass of [HypertrackPlatformInterface] for iOS overriding.
class iOSChannelHypertrack extends HypertrackPlatformInterface {
  /// The method channel used to interact with the native platform.
  final MethodChannel _methodChannel;

  final methodChannel =
      const MethodChannel('sdk.hypertrack.com/method_channel');

  /// The event channel used to interact with the native platform.
  final EventChannel _eventChannel;

  final eventChannel =
      const EventChannel('sdk.hypertrack.com/trackingState');

  iOSChannelHypertrack(this._methodChannel, this._eventChannel) : super();

  @override
  Future<HyperTrack> initialize(String publishableKey) async {
    String? result =
        await _methodChannel.invokeMethod<String>("initialize", publishableKey);
    if (result != null) {
      throw Exception(result);
    }
    return HyperTrack();
  }

  @override
  Future<bool> isRunning() async {
    bool temp = await _methodChannel.invokeMethod<bool>("isRunning") ?? false;
    return temp;
  }

  @override
  startTracking() async => await _methodChannel.invokeMethod("start");

  @override
  stopTracking() async => await _methodChannel.invokeMethod("stop");

  @override
  getDeviceId() async => await _methodChannel.invokeMethod("getDeviceId");

  @override
  addGeotag(data, expectedLocation) async =>
      await _methodChannel.invokeMethod("addGeotag", data);

  @override
  allowMockLocations(allow) async =>
      await _methodChannel.invokeMethod("allowMockLocations");

  @override
  setDeviceMetadata(data) async =>
      await _methodChannel.invokeMethod("setDeviceMetadata", data);

  @override
  setDeviceName(data) async =>
      await _methodChannel.invokeMethod('setDeviceName', data);

  @override
  syncDeviceSettings() async =>
      await _methodChannel.invokeMethod("syncDeviceSettings");
  
  @override
  void enableDebugLogging() async {
    await _methodChannel.invokeMethod("enableDebugLogging");
  }
}
