package com.hypertrack.sdk.flutter

sealed class LocationError()
object NotRunning: LocationError()
object Starting: LocationError()
data class Errors(val errors: Set<HyperTrackError>): LocationError()
