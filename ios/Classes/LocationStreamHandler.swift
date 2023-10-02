import HyperTrack

class LocationStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = HyperTrack.subscribeToLocation { locationResult in
            events(serializeLocationResult(locationResult))
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}
