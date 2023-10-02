import HyperTrack

class IsAvailableStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = HyperTrack.subscribeToIsAvailable { isAvailable in
            events(serializeIsAvailable(isAvailable))
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}
