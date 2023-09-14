import 'dart:ffi';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/sdk_method.dart';
import 'package:hypertrack_plugin/src/serialization.dart';

import 'data_types/hypertrack_error.dart';
import 'data_types/location.dart';

/// This plugin allows you to use HyperTrack SDK for Flutter apps
class HyperTrack {
  static Future<Result<Location, LocationError>> addGeotag(JSONObject data) {
    return _invokeSdkMethod<Map<Object?, Object?>>(
            SdkMethod.addGeotag, serializeGeotagData(data, null))
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  static Future<Result<LocationWithDeviation, LocationError>>
      addGeotagWithExpectedLocation(
          JSONObject data, Location expectedLocation) {
    return _invokeSdkMethod<Map<Object?, Object?>>(
            SdkMethod.addGeotag, serializeGeotagData(data, expectedLocation))
        .then((value) {
      return deserializeLocationWithDeviationResult(value);
    });
  }

  static Future<String> get deviceId async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getDeviceID)
        .then((value) {
      return deserializeDeviceId(value);
    });
  }

  static Future<Set<HyperTrackError>> get errors async {
    return _invokeSdkMethod<List<Object?>>(SdkMethod.getErrors).then((value) {
      return deserializeErrors(value.cast<Map<Object?, Object?>>());
    });
  }

  static Future<bool> get isAvailable async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getIsAvailable)
        .then((value) {
      return deserializeIsAvailable(value);
    });
  }

  static Future<bool> get isTracking async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getIsTracking)
        .then((value) {
      return deserializeIsTracking(value);
    });
  }

  static Future<Result<Location, LocationError>> get location async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getLocation)
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  static Future<JSONObject> get metadata async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getMetadata)
        .then((value) {
      return deserializeMetadata(value);
    });
  }

  static Future<String> get name async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getName)
        .then((value) {
      return deserializeName(value);
    });
  }

  static Stream<Result<Location, Set<HyperTrackError>>> locate() {
    return _locateChannel.receiveBroadcastStream().map((event) {
      return deserializeLocateResult(event);
    });
  }

  static void setIsAvailable(bool available) {
    _invokeSdkVoidMethod(
        SdkMethod.setIsAvailable, serializeIsAvailable(available));
  }

  static void setIsTracking(bool tracking) {
    _invokeSdkVoidMethod(
        SdkMethod.setIsTracking, serializeIsTracking(tracking));
  }

  static void setName(String name) {
    _invokeSdkVoidMethod(SdkMethod.setName, serializeName(name));
  }

  static void setMetadata(JSONObject data) {
    _invokeSdkVoidMethod(SdkMethod.setMetadata, serializeMetadata(data));
  }

  static Stream<Set<HyperTrackError>> get errorsSubscription {
    return _errorsChannel.receiveBroadcastStream().map((event) {
      return deserializeErrors(event.cast<Map<Object?, Object?>>());
    });
  }

  static Stream<bool> get isAvailableSubscription {
    return _isAvailableChannel.receiveBroadcastStream().map((event) {
      return deserializeIsAvailable(event);
    });
  }

  static Stream<bool> get isTrackingSubscription {
    return _isTrackingChannel.receiveBroadcastStream().map((event) {
      return deserializeIsTracking(event);
    });
  }

  static Stream<Result<Location, LocationError>> get locationSubscription {
    return _locationChannel.receiveBroadcastStream().map((event) {
      return deserializeLocationResult(event);
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

// channel for invoking SDK methods
const _methodChannel = MethodChannel('$_channelPrefix/methods');

// channels for receiving events from the SDK
const EventChannel _errorsChannel = EventChannel('$_channelPrefix/errors');
const EventChannel _isAvailableChannel =
    EventChannel('$_channelPrefix/isAvailable');
const EventChannel _isTrackingChannel =
    EventChannel('$_channelPrefix/isTracking');
const EventChannel _locationChannel = EventChannel('$_channelPrefix/location');
const EventChannel _locateChannel = EventChannel('$_channelPrefix/locate');

Future<T> _invokeSdkMethod<T>(SdkMethod method,
    [Map<Object?, Object?>? arguments]) {
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
