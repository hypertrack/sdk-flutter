// enum naming convention is ignored to make datatype sync
// across platforms easier
enum HyperTrackError {
  /// The SDK was remotely blocked from running.
  blockedFromRunning,

  /// The publishable key is invalid.
  invalidPublishableKey,

  /// The user enabled mock location app while mocking locations is prohibited.
  locationMocked,

  /// The user disabled location services systemwide.
  locationServicesDisabled,

  /// [Android only] The device doesn't have location services.
  locationServicesUnavailable,

  /// GPS satellites are not in view.
  locationSignalLost,

  /// [Android only] The SDK wasn't able to start tracking because of the limitations imposed by the OS.
  noExemptionFromBackgroundStartRestrictions,

  /// The user denied location permissions.
  permissionsLocationDenied,

  /// Can’t start tracking in background with When In Use location permissions.
  permissionsLocationInsufficientForBackground,

  /// [iOS only] The user has not chosen whether the app can use location services.
  permissionsLocationNotDetermined,

  /// [iOS only] The app is in Provisional Always authorization state, which stops sending locations when app is in background.
  permissionsLocationProvisional,

  /// The user didn't grant precise location permissions or downgraded permissions to imprecise.
  permissionsLocationReducedAccuracy,

  /// [iOS only] The app is not authorized to use location services.
  permissionsLocationRestricted,

  /// [Android only] The user denied notification permissions needed to display a persistent notification
  permissionsNotificationsDenied;

  /// @nodoc
  @override
  String toString() {
    return super.toString().split('.').last;
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
