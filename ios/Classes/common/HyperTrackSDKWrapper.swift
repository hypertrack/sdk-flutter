import HyperTrack

public enum SuccessResult {
    case void
    case string(String)
    case dict(Dictionary<String, Any>)
}
extension String: Error {}

let errorInvalidPublishableKey = "Invalid publishable key"
let errorSDKInstanceNil = "SDK instance is nil"
let errorFailedToParseMetadata = "Failed to parse metadata"

public class HyperTrackSDKWrapper {
    
    private static var sdkInstance: HyperTrack?
    
    static public func initializeSDK(
        publishableKey publishableKey: String,
        sdkInitParams sdkInitParams: SDKInitParams
    ) -> Result<SuccessResult, String> {
        let publishableKey = HyperTrack.PublishableKey(publishableKey)
        if let publishableKey = publishableKey {
            switch HyperTrack.makeSDK(publishableKey: publishableKey, mockLocationsAllowed:sdkInitParams.allowMockLocations) {
            case let .success(hyperTrack):
                sdkInstance = hyperTrack
                HyperTrack.isLoggingEnabled = sdkInitParams.loggingEnabled
                return .success(.void)
            case let .failure(fatalError):
                return .failure(serializeFatalError(fatalError: fatalError))
            }
        } else {
            return .failure(errorInvalidPublishableKey)
        }
    }
    
    static public func getDeviceID() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(.string(sdk.deviceID)) }
    }
    
    static public func getLocation() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(.dict(serializeLocationResult(sdk.location))) }
    }
    
    static public func startTracking() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(asVoid(sdk.start())) }
    }
    
    static public func stopTracking() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(asVoid(sdk.stop())) }
    }
    
    static public func setAvailability(_ availability: Dictionary<String, Any>) -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in
            let isAvailable = deserializeAvailability(availability)
            if(isAvailable) {
                sdk.availability = .available
            } else {
                sdk.availability = .unavailable
            }
            return .success(.void)
        }
    }
    
    static public func setName(_ name: String) -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(asVoid(sdk.setDeviceName(name))) }
    }
    
    static public func setMetadata(_ map: Dictionary<String, Any>) -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in
            let metadata = HyperTrack.Metadata.init(dictionary: map)
            if(metadata != nil) {
                sdk.setDeviceMetadata(metadata!)
                return .success(.void)
            } else {
                return .failure(errorFailedToParseMetadata)
            }
        }
    }
    
    static public func isTracking() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(.dict(serializeIsTracking(sdk.isTracking))) }
    }
    
    static public func isAvailable() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(.dict(serializeIsAvailable(sdk.availability))) }
    }
    
    static public func addGeotag(_ map: Dictionary<String, Any>) -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in
            let metadata = HyperTrack.Metadata.init(dictionary: map)
            if(metadata != nil) {
                sdk.addGeotag(metadata!)
                return .success(.dict(serializeLocationResult(.failure(.gpsSignalLost))))
            } else {
                return .failure(errorFailedToParseMetadata)
            }
        }
    }
    
    static public func sync() -> Result<SuccessResult, String> {
        return withSdkInstance { sdk in .success(asVoid(sdk.syncDeviceSettings())) }
    }
    
    static public func withSdkInstance(_ block: (HyperTrack) -> Result<SuccessResult, String>) -> Result<SuccessResult, String> {
        if(sdkInstance != nil) {
            return block(sdkInstance!)
        } else {
            return .failure(errorSDKInstanceNil)
        }
    }
    
}

func asVoid(_ void: Void) -> SuccessResult {
    return .void
}
