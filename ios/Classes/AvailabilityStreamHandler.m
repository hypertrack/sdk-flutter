#import "AvailabilityStreamHandler.h"
@import HyperTrack;

@implementation AvailabilityStreamHandler {
    FlutterEventSink _eventSink;
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAvailable)
                                                 name:HTSDK.becameAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUnavailable)
                                                 name:HTSDK.becameUnavailableNotification
                                               object:nil];
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

- (void)onAvailable {
//     NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"available");
}
- (void)onUnavailable {
//     NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"unavailable");
}

@end
