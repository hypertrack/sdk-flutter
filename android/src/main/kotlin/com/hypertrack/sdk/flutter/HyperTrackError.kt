package com.hypertrack.sdk.flutter

// enum naming convention is ingored to make datatype sync
// across platforms easier
enum class HyperTrackError {
    gpsSignalLost,
    locationPermissionsDenied,
    locationPermissionsInsufficientForBackground,
    locationServicesDisabled,
    motionActivityPermissionsDenied,
    invalidPublishableKey,
    permissionsDenied,
    blockedFromRunning
}
