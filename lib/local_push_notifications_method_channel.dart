import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_push_notifications_platform_interface.dart';

/// An implementation of [LocalPushNotificationsPlatform] that uses method channels.
class MethodChannelLocalPushNotifications extends LocalPushNotificationsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_push_notifications');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
