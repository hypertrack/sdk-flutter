import '../../data_types/tracking_state.dart';

TrackingStateChange deserializeTrackingState(String event) {
  switch (event) {
    case "start":
      return TrackingStateChange.start;
    case "stop":
      return TrackingStateChange.stop;
    case "publishable_key_error":
      return TrackingStateChange.invalidPublishableKey;
    case "permissions_denied":
      return TrackingStateChange.permissionsDenied;
    case "auth_error":
      return TrackingStateChange.authError;
    case "gps_disabled":
      return TrackingStateChange.locationDisabled;
    case "network_error":
      return TrackingStateChange.networkError;
  }
  return TrackingStateChange.unknownError;
}
