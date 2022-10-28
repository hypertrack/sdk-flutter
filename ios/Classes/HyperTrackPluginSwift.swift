import HyperTrack
import Flutter

let errorCodeMethodCall = "method_call_error"
let errorCodeStreamInit = "stream_init_error"

public class HyperTrackPluginSwift: NSObject, FlutterPlugin {
    private static let methodChannelName = "sdk.hypertrack.com/methods"
    private static let trackingEventChannelName = "sdk.hypertrack.com/tracking"
    private static let errorsEventChannelName = "sdk.hypertrack.com/errors"
    private static let availabilityEventChannelName = "sdk.hypertrack.com/availability"
    
    static var methodChannel: FlutterMethodChannel?
    static var trackingEventChannel: FlutterEventChannel?
    static var errorsEventChannel: FlutterEventChannel?
    static var availabilityEventChannel: FlutterEventChannel?
    
    @objc(registerWithRegistrar:)
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        let instance = HyperTrackPluginSwift()
        registrar.addMethodCallDelegate(instance, channel: methodChannel!)
        initEventChannels(messenger)
    }
    
    @objc
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let sdkMethod = SDKMethod(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        let args = call.value(forKey: "_arguments")
        let method = call.value(forKey: "_method") as! String
        
        sendAsFlutterResult(
            result: HyperTrackPluginSwift.handleMethod(sdkMethod, args),
            method: method,
            flutterResult: result
        )
    }
    
    private static func handleMethod(
        _ sdkMethod: SDKMethod,
        _ args: Any?
    ) -> Result<SuccessResult, FailureResult> {
        switch(sdkMethod) {
        case .initialize:
            let params = args as! NSDictionary
            let publishableKey = params[keyPublishableKey] as! String
            if let sdkInitParams = SDKInitParams(params) {
                return HyperTrackSDKWrapper.initializeSDK(
                    publishableKey: publishableKey,
                    sdkInitParams: sdkInitParams
                )
            } else {
                return .failure(.error("\(errorInvalidSDKInitParams) \(params)"))
            }
            
        case .getDeviceId:
            return HyperTrackSDKWrapper.getDeviceID()
            
        case .getLocation:
            return HyperTrackSDKWrapper.getLocation()
            
        case .startTracking:
            return HyperTrackSDKWrapper.startTracking()
            
        case .stopTracking:
            return HyperTrackSDKWrapper.stopTracking()
            
        case .setAvailability:
            return HyperTrackSDKWrapper.setAvailability(
                args as! Dictionary<String, Any>
            )
            
        case .setName:
            return HyperTrackSDKWrapper.setName(args as! String)
            
        case .setMetadata:
            return HyperTrackSDKWrapper.setMetadata(args as! Dictionary<String, Any>)
            
        case .isTracking:
            return HyperTrackSDKWrapper.isTracking()
            
        case .isAvailable:
            return HyperTrackSDKWrapper.isAvailable()
            
        case .addGeotag:
            return HyperTrackSDKWrapper.addGeotag(args as! Dictionary<String, Any>)
            
        case .sync:
            return HyperTrackSDKWrapper.sync()
            
        }
    }
    
    private static func initEventChannels(_ messenger: FlutterBinaryMessenger) {
        trackingEventChannel = FlutterEventChannel(name: trackingEventChannelName, binaryMessenger: messenger)
        trackingEventChannel!.setStreamHandler(TrackingEventStreamHandler())
        
        availabilityEventChannel = FlutterEventChannel(name: availabilityEventChannelName, binaryMessenger: messenger)
        availabilityEventChannel!.setStreamHandler(AvailabilityEventStreamHandler())
        
        errorsEventChannel = FlutterEventChannel(name: errorsEventChannelName, binaryMessenger: messenger)
        errorsEventChannel!.setStreamHandler(ErrorsEventStreamHandler())
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
            case .string(let value):
                flutterResult(value)
            case .dict(let value):
                flutterResult(value)
            }
        case .failure(let failure):
            switch(failure) {
            case .error(let message):
                flutterResult(FlutterError.init(code: errorCodeMethodCall,
                                                message: message,
                                                details: nil))
            case .fatalError(let message):
                preconditionFailure(message)
            }
        }
    }
}

func sendErrorIfAny(result: Result<SuccessResult, FailureResult>, channel eventSink: FlutterEventSink, errorCode: String) {
    switch result {
    case .failure(let failure):
        switch failure {
        case .fatalError(let message):
            preconditionFailure(message)
        case .error(let message):
            eventSink(FlutterError.init(code: errorCodeMethodCall,
                                        message: message,
                                        details: nil))
        }
        
    default:
        return
    }
}
