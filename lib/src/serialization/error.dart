import 'package:hypertrack_plugin/data_types/error.dart';

TrackingError deserializeTrackingError(Map<Object?, Object?> response) {
  Map<String, String> data = response.cast<String, String>();
  String? trackingError = data[_keyTrackingError];
  switch (trackingError) {
    case "gpsSignalLost":
      return TrackingError.gpsSignalLost;
    case "locationMocked":
      return TrackingError.locationMocked;
    case "locationPermissionsDenied":
      return TrackingError.locationPermissionsDenied;
    case "locationPermissionsInsufficientForBackground":
      return TrackingError.locationPermissionsInsufficientForBackground;
    case "locationPermissionsNotDetermined":
      return TrackingError.locationPermissionsNotDetermined;
    case "locationPermissionsReducedAccuracy":
      return TrackingError.locationPermissionsReducedAccuracy;
    case "locationPermissionsProvisional":
      return TrackingError.locationPermissionsProvisional;
    case "locationPermissionsRestricted":
      return TrackingError.locationPermissionsRestricted;
    case "locationServicesDisabled":
      return TrackingError.locationServicesDisabled;
    case "locationServicesUnavailable":
      return TrackingError.locationServicesUnavailable;
    case "motionActivityPermissionsNotDetermined":
      return TrackingError.motionActivityPermissionsNotDetermined;
    case "motionActivityPermissionsDenied":
      return TrackingError.motionActivityPermissionsDenied;
    case "motionActivityServicesDisabled":
      return TrackingError.motionActivityServicesDisabled;
    case "notRunning":
      return TrackingError.notRunning;
    case "starting":
      return TrackingError.starting;
    case "invalidPublishableKey":
      return TrackingError.invalidPublishableKey;
    case "blockedFromRunning":
      return TrackingError.blockedFromRunning;
    default:
      throw Exception("Invalid trackingError: ${response}");
  }
}

String _keyTrackingError = "trackingError";
