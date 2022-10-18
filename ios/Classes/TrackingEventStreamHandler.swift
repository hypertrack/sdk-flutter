import HyperTrack

class TrackingEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError), name: HyperTrack.didEncounterRestorableErrorNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError), name: HyperTrack.didEncounterUnrestorableErrorNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrackingStarted), name: HyperTrack.startedTrackingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrackingStopped), name: HyperTrack.stoppedTrackingNotification, object: nil)
        
        HyperTrackSDKWrapper.withSdkInstance { (sdk: HyperTrack) in
            eventSink!(serializeIsTracking(sdk.isTracking))
            return .success(.void)
        }.sendErrorIfAny(eventSink!, errorCode: errorCodeStreamInit)
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    @objc
    private func onTrackingStarted() {
        eventSink!(serializeIsTracking(true))
    }
    
    @objc
    private func onTrackingStopped() {
        eventSink!(serializeIsTracking(false))
    }
    
    @objc
    private func onSdkError() {
        // do nothind (handled by ErrorsEventStreamHandler)
    }
    
}
