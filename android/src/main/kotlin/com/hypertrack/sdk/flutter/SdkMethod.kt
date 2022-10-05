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
    setName,
    setMetadata,
    isTracking,
    addGeotag,
    allowMockLocations,
    enableDebugLogging,
    sync
}
