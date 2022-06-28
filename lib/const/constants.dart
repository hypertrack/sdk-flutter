/// All tracking states possible.
enum TrackingStateChange {
  /// Tracking is active
  start,

  /// Tracking stopped
  stop,

  /// Tracking doesn't happen due to missing permission(s)
  permissionsDenied,

  /// Tracking doesn't happend due to location service being disabled.
  locationDisabled,

  ///  SDK provided with incalid token.
  invalidToken,

  /// SDK encountered network error
  networkError,

  /// Tracking won't happen as either account is suspended or device was deleted
  /// from account.
  authError,

  /// SDK encountered a unknown issue, will log stack in this case
  unknownError
}

/// PossibleGeotag Errors.
enum GeotagErrorReason {
  /// User needs to grant the location data access permission
  missingLocationPermission,

  /// User needs to grant the activity data access permission
  missingActivityPermission,

  /// User needs to enable the geolocation feature in device's Settings
  locationServiceDisable,

  /// SDK doesn't track (start tracking wasn't called)
  notTracking,

  /// Tracking has started but the current device location haven't been
  /// determined yet
  locationNotDetermined,

  /// Geoposition can't be determined due to the absense of GPS signal
  noGPSSignal,

  /// Android geolocation service hangs, so app restart is required to move
  /// it from the dead point
  restartRequired
}

/// Location object
class Location {
  double longitude;
  double latitude;

  Location(this.longitude, this.latitude);
}

/// Marker interface for the `addGeotag` Response
abstract class GeotagResult {}

/// Geotag created successfully
class GeotagSuccess implements GeotagResult {}

/// Geotag with expected location was successfully created
class GeotagSuccessWithDeviation extends GeotagSuccess {
  /// Haversine distance between the expected geotag location and
  /// the actual one, where it was created in meters
  int deviation;
  GeotagSuccessWithDeviation(this.deviation);
}

/// Incapsulates the reason due to wich geotag wasn't created
class GeotagError implements GeotagResult {
  GeotagErrorReason reason;
  GeotagError(this.reason);
}
