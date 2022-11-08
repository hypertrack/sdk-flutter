import HyperTrack

class TrackingEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let eventSink = events
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(self, selector: #selector(onTrackingStarted), name: HyperTrack.startedTrackingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTrackingStopped), name: HyperTrack.stoppedTrackingNotification, object: nil)


        eventSink(serializeIsTracking(HyperTrackSDKWrapper.sdkInstance.isTracking))

        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
    
    @objc
    private func onTrackingStarted() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(serializeIsTracking(true))
    }
    
    @objc
    private func onTrackingStopped() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink(serializeIsTracking(false))
    }
}
