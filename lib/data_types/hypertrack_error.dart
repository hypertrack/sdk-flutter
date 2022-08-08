enum HyperTrackError {
  gpsSignalLost,
  locationMocked,
  locationPermissionsDenied,
  locationPermissionsInsufficientForBackground,
  locationPermissionsNotDetermined,
  locationPermissionsReducedAccuracy,
  locationPermissionsProvisional,
  locationPermissionsRestricted,
  locationServicesDisabled,
  locationServicesUnavailable,
  motionActivityPermissionsNotDetermined,
  motionActivityPermissionsDenied,
  motionActivityServicesDisabled,
  motionActivityPermissionsRestricted,
  motionActivityServicesUnavailable,
  networkConnectionUnavailable,
  invalidPublishableKey,
  blockedFromRunning;

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
  Type get runtimeType {
    return super.runtimeType;
  }
}
