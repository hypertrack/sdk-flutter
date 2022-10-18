import HyperTrack

class AvailabilityEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onAvailable), name: HyperTrack.becameAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUnavailable), name: HyperTrack.becameUnavailableNotification, object: nil)
        
        HyperTrackSDKWrapper.withSdkInstance { (sdk: HyperTrack) in
            eventSink!(serializeIsAvailable(sdk.availability))
            return .success(.void)
        }.sendErrorIfAny(eventSink!, errorCode: errorCodeStreamInit)
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    @objc
    private func onAvailable() {
        eventSink!(serializeIsAvailable(.available))
    }
    
    @objc
    private func onUnavailable() {
        eventSink!(serializeIsAvailable(.unavailable))
    }
}
