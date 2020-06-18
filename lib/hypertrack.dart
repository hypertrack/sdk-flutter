import 'dart:async';

import 'package:flutter/services.dart';

enum TrackingStateChange {
  start,
  stop,
  permissions_denied,
  location_disabled,
  invalid_token,
  network_error,
  auth_error,
  unknown_error
}


class HyperTrack {

  static Future<HyperTrack> initialize(publishableKey) async {
    final MethodChannel methodChannel =
    const MethodChannel('sdk.hypertrack.com/handle');
    await methodChannel.invokeMethod<void>('initialize', publishableKey);
    final EventChannel eventChannel =
    const EventChannel('sdk.hypertrack.com/trackingState');
    return HyperTrack(methodChannel, eventChannel);
  }

  static void enableDebugLogging() {
    const MethodChannel('sdk.hypertrack.com/handle')
        .invokeMethod('enableDebugLogging');
  }

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<TrackingStateChange> _trackingStateStream;

  HyperTrack(this._methodChannel, this._eventChannel);

  Future<String> getDeviceId() async => await _methodChannel.invokeMethod<String>('getDeviceId');

  Future<bool> isRunning() async => await _methodChannel.invokeMethod<bool>('isRunning');

  void start()  => _methodChannel.invokeMethod<void>('start');

  void stop() =>  _methodChannel.invokeMethod<void>('stop');

  void addGeotag(Map<String, Object> data) => _methodChannel.invokeMethod('addGeotag', data);

  void setDeviceName(String name) => _methodChannel.invokeMethod('setDeviceName', name);

  void setDeviceMetadata(Map<String, Object> data) => _methodChannel.invokeMethod('setDeviceMetadata', data);

  void syncDeviceSettings() => _methodChannel.invokeMethod('syncDeviceSettings');

  void allowMockLocations() => _methodChannel.invokeMethod('allowMockLocations');

  Stream<TrackingStateChange> get onTrackingStateChanged {
    if (_trackingStateStream == null) {
      _trackingStateStream = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parseStreamEvent(event));
    }
    return _trackingStateStream;
  }

  TrackingStateChange _parseStreamEvent(String event) {
    switch (event) {
      case "start":
        return TrackingStateChange.start;
      case "stop":
        return TrackingStateChange.stop;
      case "publishable_key_error":
        return TrackingStateChange.invalid_token;
      case "permissions_denied":
        return TrackingStateChange.permissions_denied;
      case "auth_error":
        return TrackingStateChange.auth_error;
      case "gps_disabled":
        return TrackingStateChange.location_disabled;
      case "network_error":
        return TrackingStateChange.network_error;

    }
    return TrackingStateChange.unknown_error;
  }
}
