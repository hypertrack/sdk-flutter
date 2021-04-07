import 'dart:async';

import 'package:flutter/services.dart';

/// Exposes tracking state details.
enum TrackingStateChange {
  /// Tracking is active
  start,

  /// Tracking stopped
  stop,

  /// Tracking doesn't happen due to missing permission(s)
  permissions_denied,

  /// Tracking doesn't happend due to location service being disabled.
  location_disabled,
  invalid_token,

  /// SDK encountered network error
  network_error,

  /// Tracking won't happen as either account is suspended or device was deleted
  /// from account.
  auth_error,
  unknown_error
}

enum GeotagResult {
  /// Geotag was created
  success,

  /// Expected location is farther then allowed from current location.
  failure_location_mismatch,

  /// Current device location isn't available.
  failure_location_not_available,

  /// Feature not supported
  failure_platform_not_supported
}

class ExpectedLocation {
  double longitude;
  double latitude;

  /// Set this to denote that geotag is not allowed to be created if distance
  /// from the device to expected location is farther then [deviation].
  bool isRestricted;

  /// Maximum distance in meters that allowed between device and expected location
  /// in case if the latter is restricted.
  ///
  /// If not set defaults to 100 meters.
  int deviation;

  ExpectedLocation(this.longitude, this.latitude,
      [this.isRestricted = false, this.deviation = 100]);
}

/// Plugin allows you to use your application as a location data source
/// feeding HyperTrack platform.
class HyperTrack {
  /// Use this method to get the SDK instance.
  ///
  /// SDK will connect to the account identified by [publishableKey].
  static Future<HyperTrack> initialize(publishableKey) async {
    final MethodChannel methodChannel =
        const MethodChannel('sdk.hypertrack.com/handle');
    await methodChannel.invokeMethod<void>('initialize', publishableKey);
    final EventChannel eventChannel =
        const EventChannel('sdk.hypertrack.com/trackingState');
    return HyperTrack(methodChannel, eventChannel);
  }

  /// Enable internal SDK logging.
  static void enableDebugLogging() {
    const MethodChannel('sdk.hypertrack.com/handle')
        .invokeMethod('enableDebugLogging');
  }

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<TrackingStateChange> _trackingStateStream;

  HyperTrack(this._methodChannel, this._eventChannel);

  /// Returns string that uniquely identifies device in HyperTrack platform.
  Future<String> getDeviceId() async =>
      await _methodChannel.invokeMethod<String>('getDeviceId');

  /// Returns `true` if tracking was started.
  ///
  /// This doesn't actually means that SDK collecting location data, but only
  /// allows you to check the current state of tracking state switch.
  /// For details on whether tracking actually happens or not check [onTrackingStateChanged] events.
  Future<bool> isRunning() async =>
      await _methodChannel.invokeMethod<bool>('isRunning');

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingStateChanged]
  /// stream to get the actual state details.
  void start() => _methodChannel.invokeMethod<void>('start');

  /// Stops tracking.
  void stop() => _methodChannel.invokeMethod<void>('stop');

  /// Adds geotag with configurable payload.
  ///
  /// Please, bear in mind that this will be serialized as json so passing in
  /// recursive data structure could lead to unpredictable results.
  /// [expectedLocation] is a place, where action is supposed to occur.
  /// Look [ExpectedLocation] class options for the details.
  Future<GeotagResult> addGeotag(Map<String, Object> data,
      [ExpectedLocation expectedLocation]) async {
    final options = {'data': data};
    if (expectedLocation != null) {
      options['expectedLocation'] = {
        'latitude': expectedLocation.latitude,
        'longitude': expectedLocation.longitude,
        'isRestricted': expectedLocation.isRestricted,
        'deviation': expectedLocation.deviation
      };
    }
    final result =
        await _methodChannel.invokeMethod<String>('addGeotag', options);
    return _asGeotagResult(result);
  }

  /// Sets current device name, that can be used for easier dashboard navigation.
  ///
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation
  /// provided. In case of frequent changes, it is possible, that intermediate
  /// states could be lost, so if more real-time responsiveness is required
  /// it is recommended to use [addGeotag] for passing that data.
  void setDeviceName(String name) =>
      _methodChannel.invokeMethod('setDeviceName', name);

  /// Sets current device data.
  ///
  /// The data can be used for easier dashboard navigation or grouping of
  /// location data in tag groups style.
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation provided.
  /// In case of frequent changes, it is possible, that intermediate states
  /// could be lost, so if more real-time responsiveness is required it is
  /// recommended to use [addGeotag] for passing that data.
  void setDeviceMetadata(Map<String, Object> data) =>
      _methodChannel.invokeMethod('setDeviceMetadata', data);

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  void syncDeviceSettings() =>
      _methodChannel.invokeMethod('syncDeviceSettings');

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  void allowMockLocations() =>
      _methodChannel.invokeMethod('allowMockLocations');

  /// Realtime updates of SDK state.
  ///
  /// Check [TrackingStateChange] for an explanation.
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

  GeotagResult _asGeotagResult(String event) {
    switch (event) {
      case "success":
        return GeotagResult.success;
      case "failure_location_mismatch":
        return GeotagResult.failure_location_mismatch;
      case "failure_location_not_available":
        return GeotagResult.failure_location_not_available;
    }
    return GeotagResult.failure_platform_not_supported;
  }
}
