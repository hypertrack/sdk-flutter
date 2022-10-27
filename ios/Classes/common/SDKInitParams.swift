private let keyLoggingEnabled = "loggingEnabled"
private let keyAllowMockLocations = "allowMockLocations"

public struct SDKInitParams {
    let loggingEnabled: Bool
    let allowMockLocations: Bool
    
    public static func fromMap(map: NSDictionary) -> SDKInitParams {
        return SDKInitParams(
            loggingEnabled: map.getOrBooleanOrNil(key: keyLoggingEnabled) ?? false,
            allowMockLocations: map.getOrBooleanOrNil(key: keyAllowMockLocations) ?? false
        )
    }
}

extension NSDictionary {
    func getOrBooleanOrNil(key: String) -> Bool? {
        let value = self[key]
        if(value is NSNull) {
            return nil
        } else {
            return value as? Bool
        }
    }
}
