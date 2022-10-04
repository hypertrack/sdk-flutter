package com.hypertrack.sdk.flutter

// enum naming convention is ingored to make datatype sync
// across platforms easier
enum class HypertrackError {
    gpsSignalLost,
    locationPermissionsDenied,
    locationServicesDisabled,
    motionActivityPermissionsDenied,
    notRunning,
    starting,
    invalidPublishableKey,
    permissionsDenied,
    blockedFromRunning
}
