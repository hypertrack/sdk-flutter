import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/hypertrack_platform_interface.dart';

import 'const/constants.dart';

/// Plugin allows you to use your application as a location data source
/// feeding HyperTrack platform.
class HyperTrack {
  final HypertrackPlatformInterface _pluginInterface =
      HypertrackPlatformInterface.instance;

  /// Use this method to get the SDK instance.
  ///
  /// SDK will connect to the account identified by [publishableKey].
  Future<HyperTrack> initialize(String publishableKey) =>
      _pluginInterface.initialize(publishableKey);

  /// Returns string that uniquely identifies device in HyperTrack platform.
  Future<String> getDeviceId() async =>
      HypertrackPlatformInterface.instance.getDeviceId();

  /// Sets current device name, that can be used for easier dashboard navigation.
  ///
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation
  /// provided. In case of frequent changes, it is possible, that intermediate
  /// states could be lost, so if more real-time responsiveness is required
  /// it is recommended to use [addGeotag] for passing that data.
  void setDeviceName(String deviceName) async =>
      _pluginInterface.setDeviceName(deviceName);

  /// Returns `true` if tracking was started.
  ///
  /// This doesn't actually means that SDK collecting location data, but only
  /// allows you to check the current state of tracking state switch.
  /// For details on whether tracking actually happens or not check [onTrackingStateChanged] events.
  Future<bool> isRunning() async {
    return await _pluginInterface.isRunning();
  }

  Future<bool> isTracking() async {
    return await _pluginInterface.isTracking();
  }

  Future<Availability> getAvailability() async {
    return await _pluginInterface.availability();
  }

  void setAvailability(bool availability) async =>
      _pluginInterface.setAvailability(availability);

  getLatestLocation() async {
    dynamic location = await _pluginInterface.getLatestLocation();
    return location;

    // Returning this -> Location[hypertrack-sdk 26.91****,75.75**** hAcc=20.0 et=0] in String
  }

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  void syncDeviceSettings() => _pluginInterface.syncDeviceSettings();

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
      _pluginInterface.setDeviceMetadata(data);

  /// Enable debugging.
  void enableDebugLogging() async {
    const MethodChannel('sdk.hypertrack.com/handle')
        .invokeMethod('enableDebugLogging');
  }

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingStateChanged]
  /// stream to get the actual state details.
  start() async {
    await _pluginInterface.startTracking();
  }

  /// Stops tracking.
  stop() async {
    await _pluginInterface.stopTracking();
  }

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  allowMockLocations([bool allow = false]) =>
      _pluginInterface.allowMockLocations(allow);

  /// Adds geotag with configurable payload.
  ///
  /// Please, bear in mind that this will be serialized as json so passing in
  /// recursive data structure could lead to unpredictable results.
  /// [expectedLocation] is a place, where action is supposed to occur.
  /// Look [ExpectedLocation] class options for the details.
  Future addGeotag(Map<String, Object> data,
          [Location? expectedLocation]) async =>
      _pluginInterface.addGeotag(data, expectedLocation);

  Stream<TrackingStateChange> get onTrackingStateChanged =>
      _pluginInterface.onTrackingStateChanged;

  /// Availability Subscription
  Stream<bool> get subscribeToAvailability => _pluginInterface.isAvailable;

  /// Tracking Subscription
  Stream<bool> subscribeToTracking(bool tracking) {
    return HypertrackPlatformInterface.instance.subscribeToTracking(tracking);
  }

  /// Errors Subscription
  Future subscribeToErrors() async {
    return await _pluginInterface.getBlockers();
  }
}
