#import "LocalNotificationsPlugin.h"
#if __has_include(<lcoal_notifications/local_notifications-Swift.h>)
#import <local_notifications/local_notifications-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "local_notifications-Swift.h"
#endif

@implementation LocalNotificationsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLocalNotificationsPlugin registerWithRegistrar:registrar];
}

@end

