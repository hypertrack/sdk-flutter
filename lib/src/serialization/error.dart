import 'package:hypertrack_plugin/data_types/error.dart';

HyperTrackError deserializeTrackingError(Map<Object?, Object?> response) {
  Map<String, String> data = response.cast<String, String>();
  String? trackingError = data[keyTrackingError];
  switch (trackingError) {
    case "gpsSignalLost":
      return HyperTrackError.gpsSignalLost;
    case "locationMocked":
      return HyperTrackError.locationMocked;
    case "permissionsDenied":
      return HyperTrackError.permissionsDenied;
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
    case "notRunning":
      return HyperTrackError.notRunning;
    case "starting":
      return HyperTrackError.starting;
    case "invalidPublishableKey":
      return HyperTrackError.invalidPublishableKey;
    case "blockedFromRunning":
      return HyperTrackError.blockedFromRunning;
    default:
      throw Exception("Invalid trackingError: ${response}");
  }
}

String keyTrackingError = "trackingError";
