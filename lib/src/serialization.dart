import 'dart:core';

import 'package:hypertrack_plugin/data_types/hypertrack_error.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';

import '../data_types/location.dart';
import '../data_types/order.dart';
import '../data_types/order_status.dart';
import '../data_types/result.dart';

const _keyType = "type";
const _keyValue = "value";

const _typeResultFailure = "failure";
const _typeResultSuccess = "success";

const _typeAllowMockLocation = "allowMockLocation";
const _typeDeviceId = "deviceID";
const _typeError = "error";
const _typeIsAvailable = "isAvailable";
const _typeIsInsideGeofence = "isInsideGeofence";
const _typeIsTracking = "isTracking";
const _typeMetadata = "metadata";
const _typeName = "name";
const _typeLocation = "location";
const _typeLocationWithDeviation = "locationWithDeviation";
const _typeOrderHandle = "orderHandle";
const _typeOrders = "orders";
const _typeWorkerHandle = "workerHandle";

const _typeOrderStatusClockIn = "orderStatusClockIn";
const _typeOrderStatusClockOut = "orderStatusClockOut";
const _typeOrderStatusCustom = "orderStatusCustom";

const _typeLocationErrorErrors = "errors";
const _typeLocationErrorNotRunning = "notRunning";
const _typeLocationErrorStarting = "starting";

const _keyLatitude = "latitude";
const _keyLongitude = "longitude";

const _keyDeviation = "deviation";
const _keyData = "data";
const _keyGeotagExpectedLocation = "expectedLocation";
const _keyLocation = "location";
const _keyOrderHandle = "orderHandle";
const _keyOrderStatus = "orderStatus";

bool deserializeAllowMockLocation(Map<Object?, Object?> allowMockLocation) {
  assert(allowMockLocation[_keyType] == _typeAllowMockLocation);
  return allowMockLocation[_keyValue] as bool;
}

String deserializeDeviceId(Map<Object?, Object?> deviceId) {
  assert(deviceId[_keyType] == _typeDeviceId);
  return deviceId[_keyValue] as String;
}

HyperTrackError deserializeError(Map<Object?, Object?> error) {
  assert(error[_keyType] == _typeError);
  switch (error[_keyValue]) {
    case "blockedFromRunning":
      return HyperTrackError.blockedFromRunning;
    case "invalidPublishableKey":
      return HyperTrackError.invalidPublishableKey;
    case "location.mocked":
      return HyperTrackError.locationMocked;
    case "location.servicesDisabled":
      return HyperTrackError.locationServicesDisabled;
    case "location.servicesUnavailable":
      return HyperTrackError.locationServicesUnavailable;
    case "location.signalLost":
      return HyperTrackError.locationSignalLost;
    case "noExemptionFromBackgroundStartRestrictions":
      return HyperTrackError.noExemptionFromBackgroundStartRestrictions;
    case "permissions.location.denied":
      return HyperTrackError.permissionsLocationDenied;
    case "permissions.location.insufficientForBackground":
      return HyperTrackError.permissionsLocationInsufficientForBackground;
    case "permissions.location.notDetermined":
      return HyperTrackError.permissionsLocationNotDetermined;
    case "permissions.location.provisional":
      return HyperTrackError.permissionsLocationProvisional;
    case "permissions.location.reducedAccuracy":
      return HyperTrackError.permissionsLocationReducedAccuracy;
    case "permissions.location.restricted":
      return HyperTrackError.permissionsLocationRestricted;
    case "permissions.notifications.denied":
      return HyperTrackError.permissionsNotificationsDenied;
    default:
      throw Exception("Unknown error type: ${error[_keyValue]}");
  }
}

Set<HyperTrackError> deserializeErrors(List<Map<Object?, Object?>> errors) {
  return errors
      .map((e) => deserializeError(e))
      .toSet();
}

Map<Object?, Object?> deserializeFailure(Map<Object?, Object?> failure) {
  assert(failure[_keyType] == _typeResultFailure);
  return failure[_keyValue] as Map<Object?, Object?>;
}

bool deserializeIsAvailable(Map<Object?, Object?> isAvailable) {
  assert(isAvailable[_keyType] == _typeIsAvailable);
  return isAvailable[_keyValue] as bool;
}

bool deserializeIsInsideGeofence(Map<Object?, Object?> isInsideGeofence) {
  assert(isInsideGeofence[_keyType] == _typeIsInsideGeofence);
  return isInsideGeofence[_keyValue] as bool;
}

Result<bool, LocationError> deserializeIsInsideGeofenceResult(
    Map<Object?, Object?> isInsideGeofenceResult) {
  switch (isInsideGeofenceResult[_keyType]) {
    case _typeResultFailure:
      return Failure(deserializeLocationError(
          deserializeFailure(isInsideGeofenceResult)));
    case _typeResultSuccess:
      return Success(deserializeIsInsideGeofence(
          deserializeSuccess(isInsideGeofenceResult)));
    default:
      throw Exception(
          "Unknown result type: ${isInsideGeofenceResult[_keyType]}");
  }
}

bool deserializeIsTracking(Map<Object?, Object?> isTracking) {
  assert(isTracking[_keyType] == _typeIsTracking);
  return isTracking[_keyValue] as bool;
}

Result<Location, Set<HyperTrackError>> deserializeLocateResult(
    Map<Object?, Object?> locationResult) {
  switch (locationResult[_keyType]) {
    case _typeResultFailure:
      return Failure(deserializeErrors(
          (locationResult[_keyValue] as List<Object?>)
              .cast<Map<Object?, Object?>>()));
    case _typeResultSuccess:
      return Success(deserializeLocation(deserializeSuccess(locationResult)));
    default:
      throw Exception("Unknown result type: ${locationResult[_keyType]}");
  }
}

LocationError deserializeLocationError(Map<Object?, Object?> locationError) {
  switch (locationError[_keyType]) {
    case _typeLocationErrorNotRunning:
      return LocationError.notRunning();
    case _typeLocationErrorStarting:
      return LocationError.starting();
    case _typeLocationErrorErrors:
      return LocationError.errors(deserializeErrors(
          (locationError[_keyValue] as List<Object?>)
              .cast<Map<Object?, Object?>>()));
    default:
      throw Exception(
          "Unknown location error type: ${locationError[_keyType]}");
  }
}

Location deserializeLocation(Map<Object?, Object?> location) {
  assert(location[_keyType] == _typeLocation);
  final value = location[_keyValue] as Map<Object?, Object?>;
  return Location(
    value[_keyLatitude] as double,
    value[_keyLongitude] as double,
  );
}

Result<Location, LocationError> deserializeLocationResult(
    Map<Object?, Object?> locationResult) {
  switch (locationResult[_keyType]) {
    case _typeResultFailure:
      return Failure(
          deserializeLocationError(deserializeFailure(locationResult)));
    case _typeResultSuccess:
      return Success(deserializeLocation(deserializeSuccess(locationResult)));
    default:
      throw Exception("Unknown result type: ${locationResult[_keyType]}");
  }
}

Result<LocationWithDeviation, LocationError>
    deserializeLocationWithDeviationResult(
        Map<Object?, Object?> locationWithDeviationResult) {
  switch (locationWithDeviationResult[_keyType]) {
    case _typeResultFailure:
      return Failure(deserializeLocationError(
          deserializeFailure(locationWithDeviationResult)));
    case _typeResultSuccess:
      return Success(deserializeLocationWithDeviation(
          deserializeSuccess(locationWithDeviationResult)));
    default:
      throw Exception(
          "Unknown result type: ${locationWithDeviationResult[_keyType]}");
  }
}

LocationWithDeviation deserializeLocationWithDeviation(
    Map<Object?, Object?> locationWithDeviation) {
  assert(locationWithDeviation[_keyType] == _typeLocationWithDeviation);
  Map<Object?, Object?> value =
      locationWithDeviation[_keyValue] as Map<Object?, Object?>;
  return LocationWithDeviation(
      deserializeLocation(value[_keyLocation] as Map<Object?, Object?>),
      value[_keyDeviation] as double);
}

JSONObject deserializeMetadata(Map<Object?, Object?> metadata) {
  assert(metadata[_keyType] == _typeMetadata);
  return fromMap(metadata[_keyValue] as Map<Object?, Object?>);
}

String deserializeName(Map<Object?, Object?> name) {
  assert(name[_keyType] == _typeName);
  return name[_keyValue] as String;
}

Map<Object?, Object?> deserializeSuccess(Map<Object?, Object?> success) {
  assert(success[_keyType] == _typeResultSuccess);
  return success[_keyValue] as Map<Object?, Object?>;
}

Order deserializeOrder(
    Map<Object?, Object?> order,
    Future<Map<Object?, Object?>> Function(String orderHandle) getIsInsideGeofence
) {
  String orderHandle = order[_keyOrderHandle] as String;
  return Order(
    () async {
      final data = await getIsInsideGeofence(orderHandle);
      return deserializeIsInsideGeofenceResult(data);
    },
    orderHandle,
  );
}

Map<String, Order> deserializeOrders(
    Map<Object?, Object?> orders,
    Future<Map<Object?, Object?>> Function(String orderHandle) getIsInsideGeofence
    ) {
  assert(orders[_keyType] == _typeOrders);
  List<Object?> ordersList = orders[_keyValue] as List<Object?>;
  Map<String, Order> result = {};
  for (Object? rawOrder in ordersList) {
    Map<Object?, Object?> order = rawOrder as Map<Object?, Object?>;
    result[order[_keyOrderHandle] as String] = deserializeOrder(
        order,
        getIsInsideGeofence
    );
  }
  return result;
}

String deserializeWorkerHandle(Map<Object?, Object?> workerHandle) {
  assert(workerHandle[_keyType] == _typeWorkerHandle);
  return workerHandle[_keyValue] as String;
}

Map<Object?, Object?> serializeAllowMockLocation(bool allowMockLocation) {
  return {
    _keyType: _typeAllowMockLocation,
    _keyValue: allowMockLocation,
  };
}

Map<Object?, Object?> serializeGeotagData(
    String? rawOrderHandle,
    OrderStatus? rawOrderStatus,
    JSONObject data,
    Location? rawExpectedLocation) {
  Map<Object?, Object?>? orderHandle;
  if (rawOrderHandle == null) {
    orderHandle = null;
  } else {
    orderHandle = serializeOrderHandle(rawOrderHandle);
  }

  Map<Object?, Object?>? orderStatus;
  if (rawOrderStatus == null) {
    orderStatus = null;
  } else {
    switch (rawOrderStatus.runtimeType) {
      case ClockIn:
        orderStatus = {
          _keyType: _typeOrderStatusClockIn,
        };
        break;
      case ClockOut:
        orderStatus = {
          _keyType: _typeOrderStatusClockOut,
        };
        break;
      case Custom:
        orderStatus = {
          _keyType: _typeOrderStatusCustom,
          _keyValue: (rawOrderStatus as Custom).value,
        };
        break;
      default:
        throw Exception(
            "Unknown order status type: ${rawOrderStatus.runtimeType}");
    }
  }

  Map<Object?, Object?>? expectedLocation;
  if (rawExpectedLocation == null) {
    expectedLocation = null;
  } else {
    expectedLocation = serializeLocation(rawExpectedLocation);
  }

  return {
    _keyOrderHandle: orderHandle,
    _keyOrderStatus: orderStatus,
    _keyData: data.serialize(),
    _keyGeotagExpectedLocation: expectedLocation,
  };
}

Map<Object?, Object?> serializeIsAvailable(bool isAvailable) {
  return {
    _keyType: _typeIsAvailable,
    _keyValue: isAvailable,
  };
}

Map<Object?, Object?> serializeIsTracking(bool isTracking) {
  return {
    _keyType: _typeIsTracking,
    _keyValue: isTracking,
  };
}

Map<Object?, Object?> serializeLocation(Location location) {
  return {
    _keyType: _typeLocation,
    _keyValue: {
      _keyLatitude: location.latitude,
      _keyLongitude: location.longitude,
    }
  };
}

Map<Object?, Object?> serializeMetadata(JSONObject metadata) {
  return {
    _keyType: _typeMetadata,
    _keyValue: metadata.serialize(),
  };
}

Map<Object?, Object?> serializeName(String name) {
  return {
    _keyType: _typeName,
    _keyValue: name,
  };
}

Map<Object?, Object?> serializeOrderHandle(String orderHandle) {
  return {
    _keyType: _typeOrderHandle,
    _keyValue: orderHandle,
  };
}

Map<Object?, Object?> serializeWorkerHandle(String workerHandle) {
  return {
    _keyType: _typeWorkerHandle,
    _keyValue: workerHandle,
  };
}
