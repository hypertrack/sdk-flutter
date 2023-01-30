import HyperTrack
import Flutter


public class HyperTrackPluginSwift: NSObject, FlutterPlugin {
    
    private let trackingEventChannel: FlutterEventChannel
    private let errorsEventChannel: FlutterEventChannel
    private let availabilityEventChannel: FlutterEventChannel
    
    public init(
        trackingEventChannel: FlutterEventChannel,
        errorsEventChannel: FlutterEventChannel,
        availabilityEventChannel: FlutterEventChannel
    ) {
        self.trackingEventChannel = trackingEventChannel
        self.errorsEventChannel = errorsEventChannel
        self.availabilityEventChannel = availabilityEventChannel
        super.init()
    }

    public func application( _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
      return false
    }
  
    @objc(registerWithRegistrar:)
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        
        let methodChannel = FlutterMethodChannel(name: "sdk.hypertrack.com/methods", binaryMessenger: messenger)
        
        let trackingEventChannel = FlutterEventChannel(name: "sdk.hypertrack.com/tracking", binaryMessenger: messenger)
        trackingEventChannel.setStreamHandler(TrackingEventStreamHandler())
        
        let availabilityEventChannel = FlutterEventChannel(name: "sdk.hypertrack.com/availability", binaryMessenger: messenger)
        availabilityEventChannel.setStreamHandler(AvailabilityEventStreamHandler())
        
        let errorsEventChannel = FlutterEventChannel(name: "sdk.hypertrack.com/errors", binaryMessenger: messenger)
        errorsEventChannel.setStreamHandler(ErrorsEventStreamHandler())
        
        let instance = HyperTrackPluginSwift(
            trackingEventChannel: trackingEventChannel, errorsEventChannel: errorsEventChannel, availabilityEventChannel: availabilityEventChannel
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        registrar.addApplicationDelegate(instance)
    }
    
    @objc
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let sdkMethod = SDKMethod(rawValue: call.method) else {
            preconditionFailure("Unknown method \(call.method)")
        }
        
        let args = call.value(forKey: "_arguments") as! Dictionary<String, Any>?
        let method = call.value(forKey: "_method") as! String
        
        sendAsFlutterResult(
            result: HyperTrackPluginSwift.handleMethod(sdkMethod, args),
            method: method,
            flutterResult: result
        )
    }
    
    private static func handleMethod(
        _ sdkMethod: SDKMethod,
        _ args: Dictionary<String, Any>?
    ) -> Result<SuccessResult, FailureResult> {
        switch(sdkMethod) {
        case .initialize:
            return initializeSDK(args!)
        case .getDeviceId:
            return getDeviceID()
            
        case .getLocation:
            return getLocation()
            
        case .startTracking:
            return startTracking()
            
        case .stopTracking:
            return stopTracking()
            
        case .setAvailability:
            return setAvailability(args!)
            
        case .setName:
            return setName(args!)
            
        case .setMetadata:
            return setMetadata(args!)
            
        case .isTracking:
            return isTracking()
            
        case .isAvailable:
            return isAvailable()
            
        case .addGeotag:
            return addGeotag(args!)
            
        case .sync:
            return sync()
            
        }
    }
    
    private func sendAsFlutterResult(
        result: Result<SuccessResult, FailureResult>,
        method: String,
        flutterResult: FlutterResult
    ) {
        switch result {
        case .success(let success):
            switch (success) {
            case .void:
                flutterResult(nil)
            case .dict(let value):
                flutterResult(value)
            }
        case .failure(let failure):
            switch(failure) {
            case .error(let message):
                flutterResult(FlutterError.init(code: "method_call_error",
                                                message: message,
                                                details: nil))
            case .fatalError(let message):
                preconditionFailure(message)
            }
        }
    }
}
