import HyperTrack

class IsTrackingStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = HyperTrack.subscribeToIsTracking { isTracking in
            events(serializeIsTracking(isTracking))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }

}
