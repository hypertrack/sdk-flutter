package com.hypertrack.sdk.flutter.common

internal sealed class LocationError
internal object NotRunning: LocationError()
internal object Starting: LocationError()
internal data class Errors(val errors: Set<HyperTrackError>): LocationError()
