import HyperTrack

class AvailabilityEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let eventSink = events
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(self, selector: #selector(onAvailable), name: HyperTrack.becameAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUnavailable), name: HyperTrack.becameUnavailableNotification, object: nil)
        
        sendErrorIfAny(
            result: HyperTrackSDKWrapper.withSdkInstance { (sdk: HyperTrack) in
                eventSink(serializeIsAvailable(sdk.availability))
                return .success(.void)
            },
            channel: eventSink,
            errorCode: errorCodeStreamInit
        )
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
    
    @objc
    private func onAvailable() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(serializeIsAvailable(.available))
    }
    
    @objc
    private func onUnavailable() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(serializeIsAvailable(.unavailable))
    }
}
