#import <Flutter/Flutter.h>

@interface HyperTrackPlugin : NSObject<FlutterPlugin>
    + (NSString*)convertErrorToMessage:(NSError*)error;

@end
