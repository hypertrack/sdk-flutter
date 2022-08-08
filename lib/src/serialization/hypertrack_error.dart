import 'package:hypertrack_plugin/src/serialization/common.dart';

import '../../data_types/hypertrack_error.dart';

Set<HyperTrackError> deserializeTrackingErrors(List<Object?> response) {
  try {
    return response.map((e) {
      final error = (e as Map).cast<String, String>();
      switch (error[keyValue]) {
        case "gpsSignalLost":
          return HyperTrackError.gpsSignalLost;
        case "locationMocked":
          return HyperTrackError.locationMocked;
        case "locationPermissionsDenied":
          return HyperTrackError.locationPermissionsDenied;
        case "locationPermissionsInsufficientForBackground":
          return HyperTrackError.locationPermissionsInsufficientForBackground;
        case "locationPermissionsNotDetermined":
          return HyperTrackError.locationPermissionsNotDetermined;
        case "locationPermissionsReducedAccuracy":
          return HyperTrackError.locationPermissionsReducedAccuracy;
        case "locationPermissionsProvisional":
          return HyperTrackError.locationPermissionsProvisional;
        case "locationPermissionsRestricted":
          return HyperTrackError.locationPermissionsRestricted;
        case "locationServicesDisabled":
          return HyperTrackError.locationServicesDisabled;
        case "locationServicesUnavailable":
          return HyperTrackError.locationServicesUnavailable;
        case "motionActivityPermissionsNotDetermined":
          return HyperTrackError.motionActivityPermissionsNotDetermined;
        case "motionActivityPermissionsDenied":
          return HyperTrackError.motionActivityPermissionsDenied;
        case "motionActivityServicesDisabled":
          return HyperTrackError.motionActivityServicesDisabled;
        case "motionActivityServicesUnavailable":
          return HyperTrackError.motionActivityServicesUnavailable;
        case "invalidPublishableKey":
          return HyperTrackError.invalidPublishableKey;
        case "blockedFromRunning":
          return HyperTrackError.blockedFromRunning;
        default:
          throw Exception("Invalid errors: ${response}");
      }
    }).toSet();
  } catch (e) {
    throw Exception("Invalid errors: ${response} $e");
  }
}
