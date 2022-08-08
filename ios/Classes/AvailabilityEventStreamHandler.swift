import HyperTrack

class AvailabilityEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var subscription: HyperTrack.Cancellable?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        subscription = sdkInstance.subscribeToAvailability(callback: { isAvailable in
            events(serializeIsAvailable(isAvailable))
        })
        events(serializeIsAvailable(sdkInstance.availability))
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        subscription?.cancel()
        subscription = nil
        return nil
    }
}
