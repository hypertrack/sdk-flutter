#import "HyperTrackPlugin.h"
#import <hypertrack_plugin/hypertrack_plugin-Swift.h>

@interface HyperTrackPlugin()
@end

@implementation HyperTrackPlugin

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [HyperTrackPluginSwift registerWithRegistrar:registrar];
}

@end
