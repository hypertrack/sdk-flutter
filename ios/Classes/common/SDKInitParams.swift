private let keyLoggingEnabled = "loggingEnabled"
private let keyAllowMockLocations = "allowMockLocations"

public struct SDKInitParams {
    let loggingEnabled: Bool
    let allowMockLocations: Bool
    
    init?(_ map: NSDictionary) {
        self.loggingEnabled = (map[keyLoggingEnabled] as? Bool) ?? false
        self.allowMockLocations = (map[keyAllowMockLocations] as? Bool) ?? false
    }
}
