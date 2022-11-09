import HyperTrack
import Foundation

class ErrorsEventStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError(notification:)), name: HyperTrack.didEncounterRestorableErrorNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSdkError(notification:)), name: HyperTrack.didEncounterUnrestorableErrorNotification, object: nil)
        // we don't send initial errors value heere because errors getter is not implemented for iOS SDK yet
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
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
            preconditionFailure("onSdkError: Unexpected SDK error \(String(describing: error))")
        }
    }
    
}
