enum TrackingStateChange {
  /// Tracking is active
  start,

  /// Tracking stopped
  stop,

  /// Tracking doesn't happen due to missing permission(s)
  permissionsDenied,

  /// Tracking doesn't happend due to location service being disabled.
  locationDisabled,

  ///  SDK provided with invalid token.
  invalidToken,

  /// SDK encountered network error
  networkError,

  /// Tracking won't happen as either account is suspended or device was deleted
  /// from account.
  authError,

  /// SDK encountered a unknown issue, will log stack in this case
  unknownError
}
