#import "FlutterUpgradePlugin.h"

@implementation FlutterUpgradePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_upgrade"
            binaryMessenger:[registrar messenger]];
  FlutterUpgradePlugin* instance = [[FlutterUpgradePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"toAppStore" isEqualToString:call.method]) {
        NSString *urlString = [[NSString alloc] initWithFormat:@"itms-apps://itunes.apple.com/app/%@?mt=8", call.arguments];
        NSURL *url = [NSURL URLWithString:urlString];
        if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {}];
        }else{
            [[UIApplication sharedApplication]openURL:url];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
