import HyperTrack

class LocateStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // there can only be only one active locate call
        subscription?.cancel()
        subscription = HyperTrack.locate { locateResult in
            events(serializeLocateResult(locateResult))
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}
