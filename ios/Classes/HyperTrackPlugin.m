#import "HyperTrackPlugin.h"
#import "TrackingStateStreamHandler.h"
#import "AvailabilityStreamHandler.h"
@import HyperTrack;

@interface HyperTrackPlugin()
@property(nonatomic) HTSDK *hyperTrack;
@end

@implementation HyperTrackPlugin

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    HyperTrackPlugin* instance = [[HyperTrackPlugin alloc] init];
    TrackingStateStreamHandler* trackingStateStreamHandler = [[TrackingStateStreamHandler alloc] init];
    AvailabilityStreamHandler* availabilityStreamHandler = [[AvailabilityStreamHandler alloc] init];
    
    FlutterMethodChannel* channel =
    [FlutterMethodChannel methodChannelWithName:@"sdk.hypertrack.com/handle"
                                binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];

    FlutterEventChannel* trackingStateEventChannel =
    [FlutterEventChannel eventChannelWithName:@"sdk.hypertrack.com/trackingState"
                              binaryMessenger:[registrar messenger]];
    [trackingStateEventChannel setStreamHandler:trackingStateStreamHandler];
    
    FlutterEventChannel* availabilityEventChannel =
    [FlutterEventChannel eventChannelWithName:@"sdk.hypertrack.com/availabilitySubscription"
                              binaryMessenger:[registrar messenger]];
    [availabilityEventChannel setStreamHandler:availabilityStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // NSLog(@"%s for method %@ with arguments %@", __PRETTY_FUNCTION__, call.method, call.arguments);
    
    if ([@"initialize" isEqualToString:call.method]) {
//        NSLog(@"Initialize SDK with publishableKey %@", call.arguments);
        HTResult *initResult = [HTSDK makeSDKWithPublishableKey: call.arguments];
        if (initResult.hyperTrack != nil) {
            self.hyperTrack = initResult.hyperTrack;
            result(nil);
        } else if (initResult.error != nil) {
            result([FlutterError errorWithCode:[HyperTrackPlugin convertErrorToMessage:initResult.error]
                                       message:initResult.error.localizedDescription
                                       details:nil]);
        }
        return;
    }
    
    if([@"enableDebugLogging" isEqualToString:call.method]) {
        HTSDK.isLoggingEnabled = [NSNumber numberWithBool:call.arguments];
        result(nil);
        return;
    }
    
    if (self.hyperTrack == nil) {
        result([FlutterError errorWithCode:@"Sdk wasn't initialized" message:@"You must initialize SDK before using it" details:nil]);
        return;
    }
    
    if([@"allowMockLocations" isEqualToString:call.method]) {
        self.hyperTrack.mockLocationsAllowed = [NSNumber numberWithBool:call.arguments];
        result(nil);
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
                [self.hyperTrack addGeotag:hyperTrackMetadata];
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
        NSNumber *available = call.arguments;
        [self.hyperTrack setAvailability:(available.boolValue ? HTAvailabilityAvailable : HTAvailabilityUnavailable)];
        result(nil);
        return;
    }
    
    if([@"getAvailability" isEqualToString:call.method]) {
        if([self.hyperTrack availability] == HTAvailabilityAvailable) {
            result(@"available");
        } else {
            result(@"unavailable");
        }
        
        return;
    }
    
    result(FlutterMethodNotImplemented);
}

+ (NSString *)convertErrorToMessage:(NSError *)error {
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

@end
