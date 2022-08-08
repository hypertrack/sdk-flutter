#import "HyperTrackPlugin.h"
@import HyperTrack;

@interface HyperTrackPlugin() <FlutterStreamHandler>
   @property(nonatomic) HTSDK *hyperTrack;
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
    NSLog(@"%s for method %@ with arguments %@", __PRETTY_FUNCTION__, call.method, call.arguments);
    
    if ([@"initialize" isEqualToString:call.method]) {
        
        NSLog(@"Initialize SDK with publishableKey %@", call.arguments);
        HTResult *initResult = [HTSDK makeSDKWithPublishableKey: call.arguments];
        if (initResult.hyperTrack != nil) {
            self.hyperTrack = initResult.hyperTrack;
            result(nil);
        } else if (initResult.error != nil) {
            result([FlutterError errorWithCode:[self convertErrorToMessage:initResult.error]
                                       message:initResult.error.localizedDescription
                                       details:nil]);
        }
        return;
    }
    
    if ([@"enableDebugLogging" isEqualToString:call.method] || [@"allowMockLocations" isEqualToString:call.method]) {
        // NOOP
        result(nil);
        return;
    }
    
    // sdk instance methods below
    if (self.hyperTrack == nil) {
        result([FlutterError errorWithCode:@"Sdk wasn't initialized" message:@"You must initialize SDK before using it" details:nil]);
        return;
    }
    
    if ([@"getDeviceId" isEqualToString:call.method]) {
        result(self.hyperTrack.deviceID);
        return;
    }
    
    if ([@"isRunning" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[self.hyperTrack isRunning]]);
        return;
    }
    
    if ([@"start" isEqualToString:call.method]) {
        [self.hyperTrack start];
        result(nil);
        return;
    }

    if ([@"stop" isEqualToString:call.method]) {
        [self.hyperTrack stop];
        result(nil);
        return;
    }
    
    if ([@"addGeotag" isEqualToString:call.method]) {
        NSDictionary *args = [[NSDictionary alloc] initWithDictionary:call.arguments];
        if (args != nil) {
            NSDictionary *expectedLocation = [[NSDictionary alloc] initWithDictionary:args[@"expectedLocation"]];
            if (expectedLocation != nil) {
                result(@"failure_platform_not_supported");
                return;
            }
            HTMetadata *hyperTrackMetadata = [[HTMetadata alloc] initWithDictionary:args[@"data"]];
            if (hyperTrackMetadata != nil) {
              [self.hyperTrack addTripMarker:hyperTrackMetadata];
              result(@"success");
              return;
            }
        } else {
          result([FlutterError errorWithCode:@"marker_metadata_error" message:@"Marker metadata should be valid key-value pairs with string keys" details:nil]);
        }
        return;
    }
    
    if ([@"setDeviceName" isEqualToString:call.method]) {
        self.hyperTrack.deviceName = call.arguments;
        result(nil);
        return;
    }
    
    if ([@"setDeviceMetadata" isEqualToString:call.method]) {
        HTMetadata *hyperTrackMetadata = [[HTMetadata alloc] initWithDictionary:call.arguments];
        if (hyperTrackMetadata != nil) {
          [self.hyperTrack setDeviceMetadata:hyperTrackMetadata];
          result(nil);
        } else {
          result([FlutterError errorWithCode:@"device_metadata_error" message:@"Device metadata should be valid key-value pairs with string keys" details:nil]);
        }
        return;
    }
    
    if ([@"syncDeviceSettings" isEqualToString:call.method]) {
        [self.hyperTrack syncDeviceSettings];
        result(nil);
        return;
    }

    if ([@"isTracking" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[self.hyperTrack isTracking]]);
        return;
    }

    if([@"getLatestLocation" isEqualToString:call.method]) {
        result([self.hyperTrack location]);
        return;
    }

    if([@"setAvailability" isEqualToString:call.method]) {
        [self.hyperTrack setAvailability:(call.arguments ? HTAvailabilityAvailable : HTAvailabilityUnavailable)];
        result(nil);
        return;
    }

    if([@"getAvailability" isEqualToString:call.method]) {
        result([NSNumber numberWithBool:[self.hyperTrack availability]]);
        return;
    }
    
    result(FlutterMethodNotImplemented);
}

- (void)onSdkError:(NSNotification*)notification {
    NSLog(@"%s notification %@", __PRETTY_FUNCTION__, notification);
    NSError* error = [notification hyperTrackTrackingError];
    if (error == nil) return;

    NSLog(@"Got error %@", error);
    _eventSink([self convertErrorToMessage:error]);
    
}

- (NSString *)convertErrorToMessage:(NSError *)error {
    switch ([error code]) {
            case HTRestorableErrorLocationPermissionsDenied:
            case HTRestorableErrorLocationServicesDisabled:
            case HTRestorableErrorMotionActivityServicesDisabled:
            case HTUnrestorableErrorMotionActivityPermissionsDenied:
            case HTFatalErrorProductionMotionActivityPermissionsDenied:
                return @"permissions_denied";
            case HTRestorableErrorTrialEnded:
            case HTRestorableErrorPaymentDefault:
               return @"auth_error";
            case HTUnrestorableErrorInvalidPublishableKey:
            case HTFatalErrorDevelopmentPublishableKeyIsEmpty:
                return @"publishable_key_error";
            
    };
    return @"unknown error";
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
