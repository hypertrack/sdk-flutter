package com.hypertrack.sdk.flutter

// enum naming convention is ingored to make datatype sync
// across platforms easier
internal enum class SdkMethod {
    initialize,
    getAvailability,
    getDeviceId,
    getLocation,
    startTracking,
    stopTracking,
    setAvailability,
    setDeviceName,
    isRunning,
    isTracking,
    addGeotag,
    allowMockLocations,
    enableDebugLogging,
    setDeviceMetadata,
    syncDeviceSettings
}
