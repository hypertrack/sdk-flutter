import HyperTrack

class ErrorsEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = sdkInstance.subscribeToErrors(callback: { errors in
            events(serializeErrors(errors))
        })
        events(serializeErrors(sdkInstance.errors))
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}
