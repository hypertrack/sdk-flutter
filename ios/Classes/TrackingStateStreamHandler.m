#import "TrackingStateStreamHandler.h"
#import "HyperTrackPlugin.h"
@import HyperTrack;

@implementation TrackingStateStreamHandler {
    FlutterEventSink _eventSink;
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSdkError:)
                                                 name:HTSDK.didEncounterRestorableErrorNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSdkError:)
                                                 name:HTSDK.didEncounterUnrestorableErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSdkStarted)
                                                 name:HTSDK.startedTrackingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSdkStopped)
                                                 name:HTSDK.stoppedTrackingNotification
                                               object:nil];
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

- (void)onSdkError:(NSNotification*)notification {
//    NSLog(@"%s notification %@", __PRETTY_FUNCTION__, notification);
    NSError* error = [notification hyperTrackTrackingError];
    if (error == nil) return;
    
//    NSLog(@"Got error %@", error);
    _eventSink([HyperTrackPlugin convertErrorToMessage:error]);
    
}

- (void)onSdkStopped {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"stop");
}
- (void)onSdkStarted {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"start");
}

@end
