import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/sdk_method.dart';
import 'package:hypertrack_plugin/src/serialization/availability.dart';
import 'package:hypertrack_plugin/src/serialization/error.dart';
import 'package:hypertrack_plugin/src/serialization/tracking_state.dart';

import 'data_types/location.dart';

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
  Future<String> get deviceId async {
    return invokeSdkMethod(SdkMethod.getDeviceId);
  }

  /// Sets current device name, that can be used for easier dashboard navigation.
  ///
  /// This setter is intended to be used for static data, that doesn't change
  /// during tracking sessions, as no SLA regarding this data propagation
  /// provided. In case of frequent changes, it is possible, that intermediate
  /// states could be lost, so if more real-time responsiveness is required
  /// it is recommended to use [addGeotag] for passing that data.
  Future<void> setName(String name) {
    return invokeSdkVoidMethod(SdkMethod.setDeviceName, name);
  }

  /// Returns `true` if tracking was started.
  ///
  /// This doesn't actually means that SDK collecting location data, but only
  /// allows you to check the current state of tracking state switch.
  /// For details on whether tracking actually happens or not check [onTrackingStateChanged] events.
  Future<bool> get isRunning async {
    return invokeSdkMethod(SdkMethod.isRunning).then((value) {
      return deserializeIsRunning(value);
    });
  }

  Future<bool> get isTracking async {
    return invokeSdkMethod(SdkMethod.isTracking).then((value) {
      return deserializeIsTracking(value);
    });
  }

  Future<bool> get isAvailable async {
    return invokeSdkMethod(SdkMethod.getAvailability).then((value) {
      return deserializeAvailability(value);
    });
  }

  Future<void> setAvailability(bool available) {
    return invokeSdkVoidMethod(
        SdkMethod.setAvailability, serializeAvailability(available));
  }

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  void syncDeviceSettings() {
    invokeSdkVoidMethod(SdkMethod.syncDeviceSettings);
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
  Future<void> setMetadata(Map<String, Object> data) {
    return invokeSdkVoidMethod(SdkMethod.setDeviceMetadata, data);
  }

  Future<Result<Location, TrackingError>> addGeotag(Map<String, Object> data) {
    return invokeSdkMethod(SdkMethod.addGeotag, data);
  }

  Future<Result<Location, TrackingError>> get location async {
    return invokeSdkMethod(SdkMethod.getLocation);
  }

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingStateChanged]
  /// stream to get the actual state details.
  void startTracking() => invokeSdkVoidMethod(SdkMethod.startTracking);

  /// Stops tracking.
  void stopTracking() => invokeSdkVoidMethod(SdkMethod.stopTracking);

  /// Allows you to use location mocking software (e.g. for development).
  ///
  /// Mock locations are ignored by HyperTrack SDK by default.
  void allowMockLocations() {
    invokeSdkVoidMethod(SdkMethod.allowMockLocations, true);
  }

  void enableDebugLogging() {
    invokeSdkVoidMethod(SdkMethod.enableDebugLogging, true);
  }

  Stream<bool> get onTrackingStateChanged {
    return _trackingStateEventChannel.receiveBroadcastStream().map((event) {
      return deserializeIsTracking(event);
    });
  }

  Stream<bool> get onAvailabilityChanged {
    return _availabilityEventChannel.receiveBroadcastStream().map((event) {
      return deserializeAvailability(event);
    });
  }

  Stream<TrackingError> get onError {
    return _errorEventChannel.receiveBroadcastStream().map((event) {
      return deserializeTrackingError(event);
    });
  }
}

const _channelPrefix = 'sdk.hypertrack.com';

// channel for invoking SDK methods
const _methodChannel = MethodChannel('$_channelPrefix/methods');

// channels for receiving events from the SDK
const EventChannel _trackingStateEventChannel =
    EventChannel('$_channelPrefix/trackingState');
const EventChannel _availabilityEventChannel =
    EventChannel('$_channelPrefix/availability');
const EventChannel _errorEventChannel =
    EventChannel('$_channelPrefix/trackingError');

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
