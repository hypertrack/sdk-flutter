import HyperTrack

enum SuccessResult {
    case void
    case string(String)
    case dict(Dictionary<String, Any>)
}
enum FailureResult: Error {
    case fatalError(_ message: String)
    case error(_ message: String)
}

let errorInvalidPublishableKey = "Invalid publishable key"
let errorInvalidSDKInitParams = "Invalid SDK init parameters"
let errorSDKInstanceNil = "SDK instance is nil"
let errorFailedToParseMetadata = "Failed to parse metadata"
let errorFailedToParseGeotagData = "Failed to parse geotag data"

class HyperTrackSDKWrapper {
    
    private static var sdkInstance: HyperTrack?
    
    static func initializeSDK(
        publishableKey: String,
        sdkInitParams: SDKInitParams
    ) -> Result<SuccessResult, FailureResult> {
        let publishableKey = HyperTrack.PublishableKey(publishableKey)
        if let publishableKey = publishableKey {
            switch HyperTrack.makeSDK(publishableKey: publishableKey, mockLocationsAllowed:sdkInitParams.allowMockLocations) {
            case let .success(hyperTrack):
                sdkInstance = hyperTrack
                HyperTrack.isLoggingEnabled = sdkInitParams.loggingEnabled
                return .success(.void)
            case let .failure(fatalError):
                return .failure(.error(serializeFatalError(fatalError: fatalError)))
            }
        } else {
            return .failure(.error(errorInvalidPublishableKey))
        }
    }
    
    static func getDeviceID() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(.string(sdk.deviceID)) }
    }
    
    static func getLocation() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(.dict(serializeLocationResult(sdk.location))) }
    }
    
    static func startTracking() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(asVoid(sdk.start())) }
    }
    
    static func stopTracking() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(asVoid(sdk.stop())) }
    }
    
    static func setAvailability(
        _ availability: Dictionary<String, Any>
    ) -> Result<SuccessResult, FailureResult> {
        deserializeAvailability(availability).flatMap { (isAvailable:Bool) in
            withSdkInstance { sdk in
                if(isAvailable) {
                    sdk.availability = .available
                } else {
                    sdk.availability = .unavailable
                }
                return .success(.void)
            }
        }
    }
    
    static func setName(_ name: String) -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(asVoid(sdk.setDeviceName(name))) }
    }
    
    static func setMetadata(_ map: Dictionary<String, Any>) -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in
            if let metadata = HyperTrack.Metadata.init(dictionary: map) {
                sdk.setDeviceMetadata(metadata)
                return .success(.void)
            } else {
                return .failure(.error(errorFailedToParseMetadata))
            }
        }
    }
    
    static func isTracking() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(.dict(serializeIsTracking(sdk.isTracking))) }
    }
    
    static func isAvailable() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(.dict(serializeIsAvailable(sdk.availability))) }
    }
    
    static func addGeotag(_ data: Dictionary<String, Any>) -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in
            if let metadata = HyperTrack.Metadata.init(dictionary: data) {
                sdk.addGeotag(metadata)
                return .success(.dict(serializeLocationResult(sdk.location)))
            } else {
                return .failure(.error(errorFailedToParseMetadata))
            }
        }
    }
    
    static func sync() -> Result<SuccessResult, FailureResult> {
        return withSdkInstance { sdk in .success(asVoid(sdk.syncDeviceSettings())) }
    }
    
    static func withSdkInstance(_ block: (HyperTrack) -> Result<SuccessResult, FailureResult>) -> Result<SuccessResult, FailureResult> {
        if let sdkInstance = sdkInstance {
            return block(sdkInstance)
        } else {
            return .failure(.error(errorSDKInstanceNil))
        }
    }
    
}

func asVoid(_ void: Void) -> SuccessResult {
    return .void
}
