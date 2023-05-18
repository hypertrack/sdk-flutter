import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/sdk_method.dart';
import 'package:hypertrack_plugin/src/serialization/availability.dart';
import 'package:hypertrack_plugin/src/serialization/device_id.dart';
import 'package:hypertrack_plugin/src/serialization/device_name.dart';
import 'package:hypertrack_plugin/src/serialization/geotag_data.dart';
import 'package:hypertrack_plugin/src/serialization/hypertrack_error.dart';
import 'package:hypertrack_plugin/src/serialization/location_result.dart';
import 'package:hypertrack_plugin/src/serialization/metadata.dart';
import 'package:hypertrack_plugin/src/serialization/tracking_state.dart';

import 'data_types/hypertrack_error.dart';
import 'data_types/location.dart';

/// This plugin allows you to use Hypertrack SDK for Flutter apps to get realtime device location
class HyperTrack {
  HyperTrack._();

  /// Creates an SDK instance
  static Future<HyperTrack> initialize(
    String publishableKey, {
    bool? requireBackgroundTrackingPermission,
    bool? loggingEnabled,
    bool? allowMockLocations,
  }) {
    return _invokeSdkVoidMethod(SdkMethod.initialize, {
      _keyPublishableKey: publishableKey,
      _keyRequireBackgroundTrackingPermission:
          requireBackgroundTrackingPermission ??= false,
      _keyLoggingEnabled: loggingEnabled ??= false,
      _keyAllowMockLocations: allowMockLocations ??= false
    }).then((value) => HyperTrack._());
  }

  /// Returns a string that is used to uniquely identify the device
  Future<String> get deviceId async {
    return _invokeSdkMethod(SdkMethod.getDeviceID).then((value) {
      return deserializeDeviceId(value);
    });
  }

  /// Reflects the tracking intent for the device
  Future<bool> get isTracking async {
    return _invokeSdkMethod(SdkMethod.isTracking).then((value) {
      return deserializeIsTracking(value);
    });
  }

  /// Reflects availability of the device for the Nearby search
  Future<bool> get isAvailable async {
    return _invokeSdkMethod(SdkMethod.isAvailable).then((value) {
      return deserializeAvailability(value);
    });
  }

  /// Expresses an intent to start location tracking for the device
  void startTracking() => _invokeSdkVoidMethod(SdkMethod.startTracking);

  /// Stops location tracking immediately
  void stopTracking() => _invokeSdkVoidMethod(SdkMethod.stopTracking);

  /// Sets the availability of the device for the Nearby search
  void setAvailability(bool available) {
    _invokeSdkVoidMethod(
        SdkMethod.setAvailability, serializeAvailability(available));
  }

  /// Sets the name for the device
  void setName(String name) {
    _invokeSdkVoidMethod(SdkMethod.setName, serializeDeviceName(name));
  }

  /// Sets the metadata for the device
  void setMetadata(JSONObject data) {
    _invokeSdkVoidMethod(SdkMethod.setMetadata, serializeMetadata(data));
  }

  /// Syncs device state with HyperTrack servers
  void sync() {
    _invokeSdkVoidMethod(SdkMethod.sync);
  }

  /// Adds a new geotag
  Future<Result<Location, LocationError>> addGeotag(JSONObject data,
      {Location? expectedLocation}) {
    return _invokeSdkMethod(
            SdkMethod.addGeotag, serializeGeotagData(data, expectedLocation))
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Reflects the current location of the user or an outage reason
  Future<Result<Location, LocationError>> get location async {
    return _invokeSdkMethod(SdkMethod.getLocation).then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Subscribe to tracking intent changes
  Stream<bool> get onTrackingChanged {
    return _trackingStateEventChannel.receiveBroadcastStream().map((event) {
      return deserializeIsTracking(event);
    });
  }

  /// Subscribe to availability changes
  Stream<bool> get onAvailabilityChanged {
    return _availabilityEventChannel.receiveBroadcastStream().map((event) {
      return deserializeAvailability(event);
    });
  }

  /// Subscribe to tracking errors
  Stream<Set<HyperTrackError>> get onError {
    return _errorEventChannel.receiveBroadcastStream().map((event) {
      return deserializeTrackingErrors(event);
    });
  }

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
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
const EventChannel _errorEventChannel = EventChannel('$_channelPrefix/errors');

Future<T> _invokeSdkMethod<T>(SdkMethod method, [dynamic arguments]) {
  return _methodChannel.invokeMethod(method.name, arguments).then((value) {
    if (value == null) {
      throw Exception("Unexpected null response for ${method.toString()}");
    } else {
      return value;
    }
  });
}

// we omit nullability check as void is encoded as null on the native side
Future<void> _invokeSdkVoidMethod(SdkMethod method, [dynamic arguments]) {
  return _methodChannel.invokeMethod(method.name, arguments);
}
