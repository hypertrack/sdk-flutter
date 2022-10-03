import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/src/sdk_methods.dart';
import 'package:hypertrack_plugin/src/serialization/availability.dart';
import 'package:hypertrack_plugin/src/serialization/tracking_state.dart';

import 'data_types/availability.dart';
import 'data_types/tracking_state.dart';

/// This plugin allows you to use Hypertrack SDK for Flutter apps to get realtime device location
class HyperTrack {
  HyperTrack._();

  /// Use this method to get the SDK instance.
  ///
  /// SDK will use the account identified by [publishableKey].
  static Future<HyperTrack> initialize(String publishableKey) {
    return invokeSdkVoidMethod(SdkMethod.initialize, publishableKey)
        .then((value) => HyperTrack._());
  }

  /// Returns string that uniquely identifies device in HyperTrack platform.
  Future<String> getDeviceId() {
    return invokeSdkMethod(SdkMethod.getDeviceId);
  }

  /// Sets current device name, that can be used for easier dashboard navigation.
  ///
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation
  /// provided. In case of frequent changes, it is possible, that intermediate
  /// states could be lost, so if more real-time responsiveness is required
  /// it is recommended to use [addGeotag] for passing that data.
  Future<void> setDeviceName(String deviceName) {
    return invokeSdkVoidMethod(SdkMethod.setDeviceName, deviceName);
  }

  /// Returns `true` if tracking was started.
  ///
  /// This doesn't actually means that SDK collecting location data, but only
  /// allows you to check the current state of tracking state switch.
  /// For details on whether tracking actually happens or not check [onTrackingStateChanged] events.
  Future<bool> isRunning() => invokeSdkMethod(SdkMethod.isRunning);

  Future<bool> isTracking() => invokeSdkMethod(SdkMethod.isTracking);

  Future<Availability> getAvailability() {
    return invokeSdkMethod(SdkMethod.getAvailability)
        .then((value) => deserializeAvailability(value));
  }

  Future<void> setAvailability(Availability availability) {
    return invokeSdkVoidMethod(
        SdkMethod.setAvailability, serializeAvailability(availability));
  }

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  Future<void> syncDeviceSettings() {
    return invokeSdkVoidMethod(SdkMethod.syncDeviceSettings);
  }

  /// Sets current device data.
  ///
  /// The data can be used for easier dashboard navigation or grouping of
  /// location data in tag groups style.
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation provided.
  /// In case of frequent changes, it is possible, that intermediate states
  /// could be lost, so if more real-time responsiveness is required it is
  /// recommended to use [addGeotag] for passing that data.
  Future<void> setDeviceMetadata(Map<String, Object> data) {
    return invokeSdkVoidMethod(SdkMethod.setDeviceMetadata, data);
  }

  Future<void> addGeotag(Map<String, Object> data) {
    return invokeSdkMethod(SdkMethod.addGeotag, data);
  }

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingStateChanged]
  /// stream to get the actual state details.
  Future<void> start() => invokeSdkVoidMethod(SdkMethod.start);

  /// Stops tracking.
  Future<void> stop() => invokeSdkVoidMethod(SdkMethod.stop);

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  Future<void> allowMockLocations() {
    return invokeSdkVoidMethod(SdkMethod.allowMockLocations, true);
  }

  Future<void> enableDebugLogging() {
    return invokeSdkVoidMethod(SdkMethod.enableDebugLogging, true);
  }

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  Stream<TrackingStateChange> get onTrackingStateChanged {
    return _trackingStateEventChannel.receiveBroadcastStream().map((event) {
      return deserializeTrackingState(event);
    });
  }

  /// Availability Subscription
  Stream<Availability> get subscribeToAvailability {
    return _availabilityEventChannel.receiveBroadcastStream().map((event) {
      return deserializeAvailability(event);
    });
  }
}

const _channelPrefix = 'sdk.hypertrack.com';
const String _notImplementedError =
    "Method is not available for the current platform";

// channel for invoking SDK methods
const _methodChannel = MethodChannel('$_channelPrefix/handle');

// channels for receiving events from the SDK
const EventChannel _trackingStateEventChannel =
    EventChannel('$_channelPrefix/trackingState');
const EventChannel _availabilityEventChannel =
    EventChannel('$_channelPrefix/availabilitySubscription');

Future<T> invokeSdkMethod<T>(SdkMethod method, [dynamic arguments]) {
  return _methodChannel.invokeMethod(method.name, arguments).then((value) {
    if (value == null) {
      throw Exception("Unexpected null response for ${method.toString()}");
    } else {
      return value;
    }
  });
}

// we omit nullability check as void is encoded as null on the native side
Future<void> invokeSdkVoidMethod(SdkMethod method, [dynamic arguments]) {
  return _methodChannel.invokeMethod(method.name, arguments);
}
