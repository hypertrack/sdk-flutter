import HyperTrack

private let keyType = "type"
private let keyValue = "value"

private let typeLocation = "location"
private let typeSuccess = "success"
private let typeFailure = "failure"
private let typeHyperTrackError = "hyperTrackError"
private let typeNotRunning = "notRunning"
private let typeStarting = "starting"
private let typeIsTracking = "isTracking"
private let typeIsAvailable = "isAvailable"

private let keyLatitude = "latitude"
private let keyLongitude = "longitude"

let keyGeotagData = "data"
let keyPublishableKey = "publishableKey"

func getHyperTrackError(_ error: HyperTrack.UnrestorableError) -> HyperTrackError {
    switch(error) {
    case .invalidPublishableKey:
        return HyperTrackError.invalidPublishableKey
    case .motionActivityPermissionsDenied:
        return HyperTrackError.locationPermissionsDenied
    }
}

func getHyperTrackError(_ error: HyperTrack.RestorableError) -> HyperTrackError {
    switch(error) {
    case .locationPermissionsNotDetermined:
        return HyperTrackError.locationPermissionsNotDetermined
    case .motionActivityPermissionsNotDetermined:
        return HyperTrackError.motionActivityPermissionsNotDetermined
    case .locationPermissionsCantBeAskedInBackground:
        return HyperTrackError.locationPermissionsNotDetermined
    case .motionActivityPermissionsCantBeAskedInBackground:
        return HyperTrackError.motionActivityPermissionsNotDetermined
    case .locationPermissionsRestricted:
        return HyperTrackError.locationPermissionsRestricted
    case .motionActivityPermissionsRestricted:
        return HyperTrackError.motionActivityPermissionsRestricted
    case .locationPermissionsDenied:
        return HyperTrackError.locationPermissionsDenied
    case .locationPermissionsInsufficientForBackground:
        return HyperTrackError.locationPermissionsInsufficientForBackground
    case .locationServicesDisabled:
        return HyperTrackError.locationServicesDisabled
    case .motionActivityServicesDisabled:
        return HyperTrackError.motionActivityServicesDisabled
    case .networkConnectionUnavailable:
        return HyperTrackError.networkConnectionUnavailable
    case .trialEnded:
        return HyperTrackError.blockedFromRunning
    case .paymentDefault:
        return HyperTrackError.blockedFromRunning
    }
}

func serializeFatalError(fatalError: HyperTrack.FatalError) -> String {
    switch fatalError {
    case .developmentError(.missingLocationUpdatesBackgroundModeCapability):
        return "missingLocationUpdatesBackgroundModeCapability"
    case .productionError(.locationServicesUnavalible):
        return "locationServicesUnavalible"
    case .developmentError(.runningOnSimulatorUnsupported):
        return "runningOnSimulatorUnsupported"
    case .productionError(.motionActivityServicesUnavalible):
        return "motionActivityServicesUnavalible"
    case .productionError(.motionActivityPermissionsDenied):
        return "motionActivityPermissionsDenied"
    }
}

func serializeLocationResult(_ result: Result<HyperTrack.Location, HyperTrack.LocationError>) -> Dictionary<String, Any>  {
    switch (result) {
    case .success(let success):
        return [
            keyType: typeSuccess,
            keyValue: [
                keyType: typeLocation,
                keyValue: [
                    keyLatitude: success.latitude,
                    keyLongitude: success.longitude
                ]
            ]
        ]
    case .failure(let failure):
        var locationError: Dictionary<String, Any>
        switch(failure) {
        case .locationPermissionsNotDetermined:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsNotDetermined)
        case .locationPermissionsCantBeAskedInBackground:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsNotDetermined)
        case .locationPermissionsInsufficientForBackground:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsInsufficientForBackground)
        case .locationPermissionsRestricted:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsRestricted)
        case .locationPermissionsReducedAccuracy:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsReducedAccuracy)
        case .locationPermissionsDenied:
            locationError = serializeHyperTrackError(HyperTrackError.locationPermissionsDenied)
        case .locationServicesDisabled:
            locationError = serializeHyperTrackError(HyperTrackError.locationServicesDisabled)
        case .motionActivityPermissionsNotDetermined:
            locationError = serializeHyperTrackError(HyperTrackError.motionActivityPermissionsNotDetermined)
        case .motionActivityPermissionsCantBeAskedInBackground:
            locationError = serializeHyperTrackError(HyperTrackError.motionActivityPermissionsNotDetermined)
        case .motionActivityPermissionsDenied:
            locationError = serializeHyperTrackError(HyperTrackError.motionActivityPermissionsDenied)
        case .motionActivityServicesDisabled:
            locationError = serializeHyperTrackError(HyperTrackError.motionActivityServicesDisabled)
            
        case .gpsSignalLost:
            locationError = serializeHyperTrackError(HyperTrackError.gpsSignalLost)
        case .locationMocked:
            locationError = serializeHyperTrackError(HyperTrackError.locationMocked)
        case .starting:
            locationError = [
                keyType: typeStarting
            ]
        case .notRunning:
            locationError = [
                keyType: typeNotRunning
            ]
        }
        
        return [
            keyType: typeFailure,
            keyValue: locationError
        ]
    }
}

func serializeHyperTrackError(_ error: HyperTrackError) -> Dictionary<String, Any> {
    return [
        keyType: typeHyperTrackError,
        keyValue: error.rawValue
    ]
}

func serializeIsTracking(_ isTracking: Bool) -> Dictionary<String, Any> {
    return [
        keyType: typeIsTracking,
        keyValue: isTracking
    ]
}

func serializeIsAvailable(_ isAvailable: HyperTrack.Availability) -> Dictionary<String, Any> {
    return [
        keyType: typeIsAvailable,
        keyValue: isAvailable == .available
    ]
}

func deserializeAvailability(_ data: Dictionary<String, Any>) -> Bool {
    assert(data[keyType] as! String == typeIsAvailable)
    return data[keyValue] as! Bool
}
