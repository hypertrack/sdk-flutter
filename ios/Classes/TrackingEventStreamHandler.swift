import HyperTrack

class TrackingEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = sdkInstance.subscribeToIsTracking(callback: { isTracking in
            events(serializeIsTracking(isTracking))
        })
        events(serializeIsTracking(sdkInstance.isTracking))
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }

}
