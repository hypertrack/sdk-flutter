import HyperTrack
import Foundation

class ErrorsEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError(notification:)), name: HyperTrack.didEncounterRestorableErrorNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError(notification:)), name: HyperTrack.didEncounterUnrestorableErrorNotification, object: nil)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
    
    @objc
    private func onTrackingStarted() {
        // do nothing (handled by TrackingEventStreamHandler)
    }
    
    @objc
    private func onTrackingStopped() {
        // do nothing (handled by TrackingEventStreamHandler)
    }
    
    @objc
    private func onSdkError(notification: Notification) {
        guard let eventSink = eventSink else {
            return
        }
        let error: HyperTrack.TrackingError? = notification.hyperTrackTrackingError()
        switch(error) {
        case .unrestorableError(let unrestorableError):
            eventSink([serializeHyperTrackError(getHyperTrackError(unrestorableError))])
        case .restorableError(let restorableError):
            eventSink([serializeHyperTrackError(getHyperTrackError(restorableError))])
        default:
            print("onSdkError: Unexpected SDK error \(error)")
        }
    }
    
}
