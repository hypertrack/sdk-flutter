import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import '../hypertrack_platform_interface.dart';

/// A subclass of [HypertrackPlatformInterface] for Android overriding.
class AndroidChannelHypertrack extends HypertrackPlatformInterface {
  /// The method channel used to interact with the native platform.
  final MethodChannel _methodChannel;

  /// The event channel used to interact with the native platform.
  final EventChannel _eventChannel;

  AndroidChannelHypertrack(this._methodChannel, this._eventChannel) : super();

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
      await _methodChannel.invokeMethod("addGeotag");

  @override
  allowMockLocations(allow) async =>
      await _methodChannel.invokeMethod("allowMockLocations");

  @override
  setDeviceMetadata(data) async =>
      await _methodChannel.invokeMethod("setDeviceMetadata", data);

  @override
  syncDeviceSettings() async =>
      await _methodChannel.invokeMethod("syncDeviceSettings");
}
