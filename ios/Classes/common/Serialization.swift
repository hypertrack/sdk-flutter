import HyperTrack

private let keyType = "type"
private let keyValue = "value"

private let typeLocation = "location"
private let typeSuccess = "success"
private let typeFailure = "failure"
private let typeHyperTrackError = "hyperTrackError"
private let typeLocationErrorNotRunning = "notRunning"
private let typeLocationErrorStarting = "starting"
private let typeLocationErrorErrors = "errors"
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
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsNotDetermined)
        case .locationPermissionsCantBeAskedInBackground:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsNotDetermined)
        case .locationPermissionsInsufficientForBackground:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsInsufficientForBackground)
        case .locationPermissionsRestricted:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsRestricted)
        case .locationPermissionsReducedAccuracy:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsReducedAccuracy)
        case .locationPermissionsDenied:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationPermissionsDenied)
        case .locationServicesDisabled:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationServicesDisabled)
        case .motionActivityPermissionsNotDetermined:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.motionActivityPermissionsNotDetermined)
        case .motionActivityPermissionsCantBeAskedInBackground:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.motionActivityPermissionsNotDetermined)
        case .motionActivityPermissionsDenied:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.motionActivityPermissionsDenied)
        case .motionActivityServicesDisabled:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.motionActivityServicesDisabled)
            
        case .gpsSignalLost:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.gpsSignalLost)
        case .locationMocked:
            locationError = serializeHyperTrackErrorAsLocationError(HyperTrackError.locationMocked)
        case .starting:
            locationError = [
                keyType: typeLocationErrorStarting
            ]
        case .notRunning:
            locationError = [
                keyType: typeLocationErrorNotRunning
            ]
        }
        
        return [
            keyType: typeFailure,
            keyValue: locationError
        ]
    }
}

func serializeHyperTrackErrorAsLocationError(_ error: HyperTrackError) -> Dictionary<String, Any> {
    return [
        keyType: typeLocationErrorErrors,
        keyValue: [
            [
                keyType: typeHyperTrackError,
                keyValue: error.rawValue
            ]
        ]
    ]
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

func deserializeAvailability(_ data: Dictionary<String, Any>) -> Result<Bool, FailureResult> {
    if(data[keyType] as? String != typeIsAvailable) {
        return .failure(.fatalError(getParseError(data, key: keyType)))
    }
    guard let value = data[keyValue] as? Bool else {
        return .failure(.fatalError(getParseError(data, key: keyValue)))
    }
    return .success(value)
}

func deserializeGeotagData(
    _ data: Dictionary<String, Any>
) -> Result<Dictionary<String, Any>, FailureResult> {
    guard let data = data[keyGeotagData] as? Dictionary<String, Any> else {
        return .failure(.fatalError(getParseError(data, key: keyGeotagData)))
    }
    return .success(data)
}

func getParseError(_ data: Any, key: String) -> String {
    return "Invalid input for key \(key): \(data)"
}
