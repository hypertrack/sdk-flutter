import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/android/hypertrack_flutter_plugin_android_channel.dart';
import 'package:hypertrack_plugin/hypertrack.dart';
import 'package:hypertrack_plugin/ios/ios_channel.dart';
import 'const/constants.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class HypertrackPlatformInterface extends PlatformInterface {
  static const String _methodUnavailableError = "Method not found for the current platform";
  static const MethodChannel _methodChannel =
      MethodChannel('sdk.hypertrack.com/handle');

  /// The event channel used to interact with the native platform.
  static const EventChannel _eventChannel =
      EventChannel('sdk.hypertrack.com/trackingState');

  Stream<TrackingStateChange>? _trackingStateStream;

  /// Constructs a HypertrackFlutterPluginPlatform.
  HypertrackPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [HypertrackPlatformInterface] to use.

  factory HypertrackPlatformInterface._getInstance() {
    if (Platform.isAndroid) {
      return AndroidChannelHypertrack(_methodChannel, _eventChannel);
    }
    if (Platform.isIOS) {
      return iOSChannelHypertrack(_methodChannel, _eventChannel);
    }
    throw Exception("The current Platform ${Platform.operatingSystem} is not "
        "yet "
        "supported");
  }

  static HypertrackPlatformInterface get instance =>
      HypertrackPlatformInterface._getInstance();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HypertrackPlatformInterface] when
  /// they register themselves.
  static set instance(HypertrackPlatformInterface newInstance) {
    PlatformInterface.verifyToken(newInstance, _token);
    instance = newInstance;
  }

  void enableDebugLogging() async => instance.enableDebugLogging();

  Future<HyperTrack> initialize(String publishableKey) async {
    const MethodChannel methodChannel =
        MethodChannel('sdk.hypertrack.com/handle');
    String? result =
        await methodChannel.invokeMethod<String>("initialize", publishableKey);
    if (result != null) {
      throw Exception(result);
    }
    return HyperTrack();
  }

  /// Returns string that uniquely identifies device in HyperTrack platform.
  Future<String> getDeviceId() async => instance.getDeviceId();

  /// UnimplementedError for setDeviceName method.
  void setDeviceName(String name) =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for isRunning method.
  Future<bool> isRunning() =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for startTracking method.
  startTracking() =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for stopTracking method.
  stopTracking() =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for addGeotag method.
  addGeotag(data, expectedLocation) =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for allowMockLocations method.
  allowMockLocations(allow) =>
      throw UnimplementedError(_methodUnavailableError);

  /// UnimplementedError for setDeviceMetadata method.
  setDeviceMetadata(data) =>
      throw UnimplementedError(_methodUnavailableError);

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  syncDeviceSettings() => _methodChannel.invokeMethod('syncDeviceSettings');

  Stream<bool> get isRunningStatus {
    Stream<bool>? a = _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event == 'start');
    return a;
  }

  Stream<TrackingStateChange> get onTrackingStateChanged {
    _trackingStateStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseStreamEvent(event));
    return _trackingStateStream!;
  }

  TrackingStateChange _parseStreamEvent(String event) {
    switch (event) {
      case "start":
        return TrackingStateChange.start;
      case "stop":
        return TrackingStateChange.stop;
      case "publishable_key_error":
        return TrackingStateChange.invalidToken;
      case "permissions_denied":
        return TrackingStateChange.permissionsDenied;
      case "auth_error":
        return TrackingStateChange.authError;
      case "gps_disabled":
        return TrackingStateChange.locationDisabled;
      case "network_error":
        return TrackingStateChange.networkError;
    }
    return TrackingStateChange.unknownError;
  }
}
