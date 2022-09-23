import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/src/sdk_wrapper.dart';

import 'data_types/availability.dart';
import 'data_types/location.dart';
import 'data_types/tracking_state.dart';

/// This plugin allows you to use Hypertrack SDK for Flutter apps to get realtime device location
class HyperTrack {
  HyperTrack._();
  static final HypertrackSdkWrapper _sdkWrapper = HypertrackSdkWrapper.instance;

  /// Use this method to get the SDK instance.
  ///
  /// SDK will use the account identified by [publishableKey].
  static Future<HyperTrack> initialize(String publishableKey) =>
      _sdkWrapper.initialize(publishableKey)
          .then((value) => HyperTrack._());

  /// Returns string that uniquely identifies device in HyperTrack platform.
  Future<String> getDeviceId() async =>
      _sdkWrapper.getDeviceId();

  /// Sets current device name, that can be used for easier dashboard navigation.
  ///
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation
  /// provided. In case of frequent changes, it is possible, that intermediate
  /// states could be lost, so if more real-time responsiveness is required
  /// it is recommended to use [addGeotag] for passing that data.
  Future<void> setDeviceName(String deviceName) async =>
      _sdkWrapper.setDeviceName(deviceName);

  /// Returns `true` if tracking was started.
  ///
  /// This doesn't actually means that SDK collecting location data, but only
  /// allows you to check the current state of tracking state switch.
  /// For details on whether tracking actually happens or not check [onTrackingStateChanged] events.
  Future<bool> isRunning() =>
      _sdkWrapper.isRunning();

  Future<bool> isTracking() =>
      _sdkWrapper.isTracking();

  Future<Availability> getAvailability() =>
      _sdkWrapper.getAvailability();

  Future<void> setAvailability(Availability availability) async =>
      _sdkWrapper.setAvailability(availability);

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  Future<void> syncDeviceSettings() async => _sdkWrapper.syncDeviceSettings();

  /// Sets current device data.
  ///
  /// The data can be used for easier dashboard navigation or grouping of
  /// location data in tag groups style.
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation provided.
  /// In case of frequent changes, it is possible, that intermediate states
  /// could be lost, so if more real-time responsiveness is required it is
  /// recommended to use [addGeotag] for passing that data.
  Future<void> setDeviceMetadata(Map<String, Object> data) async =>
      _sdkWrapper.setDeviceMetadata(data);

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingStateChanged]
  /// stream to get the actual state details.
  Future<void> start() async => _sdkWrapper.startTracking();

  /// Stops tracking.
  Future<void> stop() async => _sdkWrapper.stopTracking();

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  Future<void> allowMockLocations() =>
      _sdkWrapper.allowMockLocations();

  Future<void> enableDebugLogging() =>
      _sdkWrapper.enableDebugLogging();

  /// Adds geotag with configurable payload.
  ///
  /// Please, bear in mind that this will be serialized as json so passing in
  /// recursive data structure could lead to unpredictable results.
  /// [expectedLocation] is a place, where action is supposed to occur.
  /// Look [ExpectedLocation] class options for the details.
  Future addGeotag(Map<String, Object> data,
          [Location? expectedLocation]) async =>
      _sdkWrapper.addGeotag(data, expectedLocation);

  Stream<TrackingStateChange> get onTrackingStateChanged =>
      _sdkWrapper.onTrackingStateChanged;

  /// Availability Subscription
  Stream<Availability> get subscribeToAvailability =>
      _sdkWrapper.onAvailabilityChanged;

}
