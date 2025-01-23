import 'package:flutter/services.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';
import 'package:hypertrack_plugin/data_types/result.dart';
import 'package:hypertrack_plugin/src/sdk_method.dart';
import 'package:hypertrack_plugin/src/serialization.dart';

import 'data_types/hypertrack_error.dart';
import 'data_types/location.dart';
import 'data_types/order.dart';
import 'data_types/order_status.dart';

/// This plugin allows you to use HyperTrack SDK for Flutter apps
class HyperTrack {
  /// Adds a new geotag. Check [Shift tracking](https://hypertrack.com/docs/shift-tracking) and [Clock In/Out tagging](https://hypertrack.com/docs/clock-inout-tracking) docs to learn how to use Order handle and Order status params.
  /// Accepts:
  /// - orderHandle - Order handle.
  /// - orderStatus - Order status.
  /// - [data] - Geotag data JSON.
  /// Returns current location if success or [LocationError] if failure.
  static Future<Result<Location, LocationError>> addGeotag(
      String orderHandle, OrderStatus orderStatus, JSONObject data) {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.addGeotag,
            serializeGeotagData(orderHandle, orderStatus, data, null))
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Adds a new geotag with expected location. Check [Shift tracking](https://hypertrack.com/docs/shift-tracking) doc to learn how to use Order handle and Order status params.
  /// Accepts:
  /// - orderHandle - Order handle.
  /// - orderStatus - Order status.
  /// - [data] - Geotag data JSON.
  /// - [expectedLocation] - Expected location.
  /// Returns current location with deviation from expected location if success
  /// or [LocationError] if failure.
  static Future<Result<LocationWithDeviation, LocationError>>
      addGeotagWithExpectedLocation(String orderHandle, OrderStatus orderStatus,
          JSONObject data, Location expectedLocation) {
    return _invokeSdkMethod<Map<Object?, Object?>>(
            SdkMethod.addGeotag,
            serializeGeotagData(
                orderHandle, orderStatus, data, expectedLocation))
        .then((value) {
      return deserializeLocationWithDeviationResult(value);
    });
  }

  /// Deprecated. Use addGeotag with orderHandle and orderStatus instead.
  static Future<Result<Location, LocationError>> addGeotagDeprecated(
      JSONObject data) {
    return _invokeSdkMethod<Map<Object?, Object?>>(
            SdkMethod.addGeotag, serializeGeotagData(null, null, data, null))
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Deprecated. Use addGeotagWithExpectedLocation with orderHandle and orderStatus instead.
  static Future<Result<LocationWithDeviation, LocationError>>
      addGeotagWithExpectedLocationDeprecated(
          JSONObject data, Location expectedLocation) {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.addGeotag,
            serializeGeotagData(null, null, data, expectedLocation))
        .then((value) {
      return deserializeLocationWithDeviationResult(value);
    });
  }

  /// If disallowed, the HyperTrack platform will display and outage if mocked location is detected
  static Future<bool> get allowMockLocation async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getAllowMockLocation)
        .then((value) {
      return deserializeAllowMockLocation(value);
    });
  }

  /// Returns a string that is used to uniquely identify the device.
  static Future<String> get deviceId async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getDeviceID)
        .then((value) {
      return deserializeDeviceId(value);
    });
  }

  /// Returns a list of errors that blocks the SDK from tracking.
  static Future<Set<HyperTrackError>> get errors async {
    return _invokeSdkMethod<List<Object?>>(SdkMethod.getErrors).then((value) {
      return deserializeErrors(value.cast<Map<Object?, Object?>>());
    });
  }

  /// Reflects availability of the device for the Nearby search.
  static Future<bool> get isAvailable async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getIsAvailable)
        .then((value) {
      return deserializeIsAvailable(value);
    });
  }

  /// Reflects the tracking intent for the device.
  static Future<bool> get isTracking async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getIsTracking)
        .then((value) {
      return deserializeIsTracking(value);
    });
  }

  /// Reflects the current location of the user or an outage reason.
  static Future<Result<Location, LocationError>> get location async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getLocation)
        .then((value) {
      return deserializeLocationResult(value);
    });
  }

  /// Gets the metadata that is set for the device.
  static Future<JSONObject> get metadata async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getMetadata)
        .then((value) {
      return deserializeMetadata(value);
    });
  }

  /// Gets the name that is set for the device.
  static Future<String> get name async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getName)
        .then((value) {
      return deserializeName(value);
    });
  }

  /// Gets the active orders for the worker. The orders are sorted with the
  /// ordering in which the worker should complete them.
  static Future<Map<String, Order>> get orders async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getOrders)
        .then((value) {
      return deserializeOrders(value);
    });
  }

  /// A primary identifier that uniquely identifies the worker outside of
  /// HyperTrack.
  /// Example: email, phone number, database id
  /// It is usually obtained and set when the worker logs into the app.
  /// Set it to an empty string "" when the worker logs out of the app to
  /// un-bind the device from the worker and avoid unintentional tracking.
  static Future<String> get workerHandle async {
    return _invokeSdkMethod<Map<Object?, Object?>>(SdkMethod.getWorkerHandle)
        .then((value) {
      return deserializeWorkerHandle(value);
    });
  }

  /// Requests one-time location update and returns the [Location] once it is
  /// available, or [LocationError].
  static Stream<Result<Location, Set<HyperTrackError>>> locate() {
    return _locateChannel.receiveBroadcastStream().map((event) {
      return deserializeLocateResult(event);
    });
  }

  /// Allows mocking location data.
  ///
  /// Check the [Test with mock locations](https://hypertrack.com/docs/mock-location)
  /// guide for more information.
  ///
  /// To avoid issues related to race conditions in your code use this API **only if**
  /// modifying the compiled `HyperTrackAllowMockLocation` AndroidManifest.xml/Info.plist
  /// value is insufficient for your needs.
  /// Example: if for some reason you aren't able to recompile with `HyperTrackAllowMockLocation`
  /// set to `YES`/`true` for your prod app QA mock location tests and need to set
  /// up the value in runtime.
  static void setAllowMockLocation(bool allow) {
    _invokeSdkVoidMethod(
        SdkMethod.setAllowMockLocation, serializeAllowMockLocation(allow));
  }

  /// Sets the availability of the device for the Nearby search.
  static void setIsAvailable(bool available) {
    _invokeSdkVoidMethod(
        SdkMethod.setIsAvailable, serializeIsAvailable(available));
  }

  /// Sets the tracking intent for the device.
  static void setIsTracking(bool tracking) {
    _invokeSdkVoidMethod(
        SdkMethod.setIsTracking, serializeIsTracking(tracking));
  }

  /// Sets the metadata for the device.
  static void setMetadata(JSONObject data) {
    _invokeSdkVoidMethod(SdkMethod.setMetadata, serializeMetadata(data));
  }

  /// Sets the name for the device.
  static void setName(String name) {
    _invokeSdkVoidMethod(SdkMethod.setName, serializeName(name));
  }

  /// A primary identifier that uniquely identifies the worker outside of HyperTrack.
  /// Example: email, phone number, database id
  /// It is usually obtained and set when the worker logs into the app.
  /// Set it to an empty string "" when the worker logs out of the app to un-bind the device from the worker and
  /// avoid unintentional tracking.
  static void setWorkerHandle(String workerHandle) {
    _invokeSdkVoidMethod(
        SdkMethod.setWorkerHandle, serializeWorkerHandle(workerHandle));
  }

  /// Subscribe to tracking errors.
  static Stream<Set<HyperTrackError>> get errorsSubscription {
    return _errorsChannel.receiveBroadcastStream().map((event) {
      return deserializeErrors(event.cast<Map<Object?, Object?>>());
    });
  }

  /// Subscribe to availability changes.
  static Stream<bool> get isAvailableSubscription {
    return _isAvailableChannel.receiveBroadcastStream().map((event) {
      return deserializeIsAvailable(event);
    });
  }

  /// Subscribe to tracking intent changes.
  static Stream<bool> get isTrackingSubscription {
    return _isTrackingChannel.receiveBroadcastStream().map((event) {
      return deserializeIsTracking(event);
    });
  }

  /// Subscribe to location changes.
  static Stream<Result<Location, LocationError>> get locationSubscription {
    return _locationChannel.receiveBroadcastStream().map((event) {
      return deserializeLocationResult(event);
    });
  }

  /// Subscribe to changes in the orders assigned to the worker
  static Stream<Map<String, Order>> get ordersSubscription {
    return _ordersChannel.receiveBroadcastStream().map((event) {
      return deserializeOrders(event);
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
const EventChannel _ordersChannel = EventChannel('$_channelPrefix/orders');

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
