import 'dart:core';

import 'package:hypertrack_plugin/data_types/hypertrack_error.dart';
import 'package:hypertrack_plugin/data_types/json.dart';
import 'package:hypertrack_plugin/data_types/location_error.dart';
import 'package:hypertrack_plugin/data_types/location_with_deviation.dart';

import '../data_types/location.dart';
import '../data_types/result.dart';

const _keyType = "type";
const _keyValue = "value";

const _typeResultFailure = "failure";
const _typeResultSuccess = "success";

const _typeDeviceId = "deviceID";
const _typeError = "error";
const _typeIsAvailable = "isAvailable";
const _typeIsTracking = "isTracking";
const _typeMetadata = "metadata";
const _typeName = "name";
const _typeLocation = "location";
const _typeLocationWithDeviation = "locationWithDeviation";

const _typeLocationErrorErrors = "errors";
const _typeLocationErrorNotRunning = "notRunning";
const _typeLocationErrorStarting = "starting";

const _keyLatitude = "latitude";
const _keyLongitude = "longitude";

const _keyDeviation = "deviation";
const _keyGeotagData = "data";
const _keyGeotagExpectedLocation = "expectedLocation";
const _keyLocation = "location";

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
      .map((e) => deserializeError(e as Map<Object?, Object?>))
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

bool deserializeIsTracking(Map<Object?, Object?> isTracking) {
  assert(isTracking[_keyType] == _typeIsTracking);
  return isTracking[_keyValue] as bool;
}

JSONObject deserializeMetadata(Map<Object?, Object?> metadata) {
  assert(metadata[_keyType] == _typeMetadata);
  return fromMap(metadata[_keyValue] as Map<Object?, Object?>);
}

String deserializeName(Map<Object?, Object?> name) {
  assert(name[_keyType] == _typeName);
  return name[_keyValue] as String;
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

Map<Object?, Object?> deserializeSuccess(Map<Object?, Object?> success) {
  assert(success[_keyType] == _typeResultSuccess);
  return success[_keyValue] as Map<Object?, Object?>;
}

Map<Object?, Object?> serializeGeotagData(
    JSONObject data, Location? rawExpectedLocation) {
  Map<Object?, Object?>? expectedLocation;
  if (rawExpectedLocation == null) {
    expectedLocation = null;
  } else {
    expectedLocation = serializeLocation(rawExpectedLocation);
  }
  return {
    _keyGeotagData: data.serialize(),
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
