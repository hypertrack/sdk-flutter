package com.hypertrack.sdk.flutter.common

// enum naming convention is ignored to make datatype sync
// across platforms easier
@Suppress("EnumEntryName")
enum class HyperTrackError {
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
    networkConnectionUnavailable,
    invalidPublishableKey,
    blockedFromRunning
}
