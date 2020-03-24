#import "HyperTrackPlugin.h"

@interface HyperTrackPlugin() <FlutterStreamHandler>
@end

@implementation HyperTrackPlugin {
    FlutterEventSink _eventSink;

}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    

  HyperTrackPlugin* instance = [[HyperTrackPlugin alloc] init];
    
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"sdk.hypertrack.com/handle"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
    
  FlutterEventChannel* stateChannel =
      [FlutterEventChannel eventChannelWithName:@"sdk.hypertrack.com/trackingState"
                                binaryMessenger:[registrar messenger]];
  [stateChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"%s for method %@", __PRETTY_FUNCTION__, call.method);
    result(@"42");
    
//  if ([@"getPlatformVersion" isEqualToString:call.method]) {
//    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
//  } else {
//    result(FlutterMethodNotImplemented);
//  }
}
- (void)onSdkError:(NSNotification*)notification {
    NSLog(@"%s notification %@", __PRETTY_FUNCTION__, notification);
//    NSError* error = [notification hyperTrackTrackingError];
//
//    NSLog(@"Got error %@", error);
//    switch ([error code]) {
//            case HTRestorableErrorLocationPermissionsDenied:
//            case HTRestorableErrorLocationServicesDisabled:
//            case HTRestorableErrorMotionActivityServicesDisabled:
//            case HTUnrestorableErrorMotionActivityPermissionsDenied:
//            case HTFatalErrorProductionMotionActivityPermissionsDenied:
//              result(@"permission_denied");
//              break;
//            case HTRestorableErrorTrialEnded:
//            case HTRestorableErrorPaymentDefault:
//              return [NSNumber numberWithInteger:authorizationError];
//              break;
//            case HTUnrestorableErrorInvalidPublishableKey:
//            case HTFatalErrorDevelopmentPublishableKeyIsEmpty:
//    };
    
}

- (void)onSdkStopped {
  NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"stop");
}
- (void)onSdkStarted {
  NSLog(@"%s", __PRETTY_FUNCTION__);
    _eventSink(@"start");
}
#pragma mark FlutterStreamHandler impl

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

@end
