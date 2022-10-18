import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/sdk_method.dart';
import 'package:hypertrack_plugin/src/serialization/availability.dart';
import 'package:hypertrack_plugin/src/serialization/geotag.dart';
import 'package:hypertrack_plugin/src/serialization/hypertrack_error.dart';
import 'package:hypertrack_plugin/src/serialization/location_result.dart';
import 'package:hypertrack_plugin/src/serialization/metadata.dart';
import 'package:hypertrack_plugin/src/serialization/tracking_state.dart';

import 'data_types/hypertrack_error.dart';
import 'data_types/location.dart';

/// This plugin allows you to use Hypertrack SDK for Flutter apps to get realtime device location
class HyperTrack {
  HyperTrack._();

  /// Use this method to get the SDK instance.
  ///
  /// SDK will use the account identified by [publishableKey].
  static Future<HyperTrack> initialize(
    String publishableKey, {
    bool? requireBackgroundTrackingPermission,
    bool? loggingEnabled,
    bool? allowMockLocations,
  }) {
    return invokeSdkVoidMethod(SdkMethod.initialize, {
      _keyPublishableKey: publishableKey,
      _keyRequireBackgroundTrackingPermission:
          requireBackgroundTrackingPermission,
      _keyLoggingEnabled: loggingEnabled,
      _keyAllowMockLocations: allowMockLocations
    }).then((value) => HyperTrack._());
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
  void setName(String name) {
    invokeSdkVoidMethod(SdkMethod.setName, name);
  }

  Future<bool> get isTracking async {
    return invokeSdkMethod(SdkMethod.isTracking).then((value) {
      return deserializeIsTracking(value);
    });
  }

  Future<bool> get isAvailable async {
    return invokeSdkMethod(SdkMethod.isAvailable).then((value) {
      return deserializeAvailability(value);
    });
  }

  void setAvailability(bool available) {
    invokeSdkVoidMethod(
        SdkMethod.setAvailability, serializeAvailability(available));
  }

  /// This method checks with HyperTrack cloud whether to start or stop tracking.
  ///
  /// Tracking starts when Devices or Trips API is used to either to start
  /// the device tracking or when a trip is created for this device.
  void sync() {
    invokeSdkVoidMethod(SdkMethod.sync);
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
  void setMetadata(JSONObject data) {
    invokeSdkVoidMethod(SdkMethod.setMetadata, serializeMetadata(data));
  }

  Future<Result<Location, LocationError>> addGeotag(JSONObject data) {
    return invokeSdkMethod(SdkMethod.addGeotag, serializeGeotag(data))
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  Future<Result<Location, LocationError>> get location async {
    return invokeSdkMethod(SdkMethod.getLocation).then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Triggers tracking start.
  ///
  /// This isn't always result in SDK tracking, as missing permissions or disabled
  /// geolocation sensors could lead to a tracking outage. Use [onTrackingChanged]
  /// stream to get the actual state details.
  void startTracking() => invokeSdkVoidMethod(SdkMethod.startTracking);

  /// Stops tracking.
  void stopTracking() => invokeSdkVoidMethod(SdkMethod.stopTracking);

  Stream<bool> get onTrackingChanged {
    return _trackingStateEventChannel.receiveBroadcastStream().map((event) {
      return deserializeIsTracking(event);
    });
  }

  Stream<bool> get onAvailabilityChanged {
    return _availabilityEventChannel.receiveBroadcastStream().map((event) {
      return deserializeAvailability(event);
    });
  }

  Stream<Set<HyperTrackError>> get onError {
    return _errorEventChannel.receiveBroadcastStream().map((event) {
      return deserializeTrackingErrors(event);
    });
  }
}

const _channelPrefix = 'sdk.hypertrack.com';
const _keyPublishableKey = 'publishableKey';
const _keyRequireBackgroundTrackingPermission =
    'requireBackgroundTrackingPermission';
const _keyLoggingEnabled = 'loggingEnabled';
const _keyAllowMockLocations = 'allowMockLocations';

// channel for invoking SDK methods
const _methodChannel = MethodChannel('$_channelPrefix/methods');

// channels for receiving events from the SDK
const EventChannel _trackingStateEventChannel =
    EventChannel('$_channelPrefix/tracking');
const EventChannel _availabilityEventChannel =
    EventChannel('$_channelPrefix/availability');
const EventChannel _errorEventChannel =
    EventChannel('$_channelPrefix/errors');

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
