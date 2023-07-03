import 'dart:io';

import 'package:local_push_notifications/i_local_notifications.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_notifications_empty.dart';
import 'local_notifications_method_channel.dart';

abstract class LocalNotificationsPlatform extends PlatformInterface
    implements ILocalNotifications {
  /// Constructs a LocalNotificationsPlatform.
  LocalNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalNotificationsPlatform _instance = Platform.isIOS
      ? MethodChannelLocalNotifications()
      : Platform.isAndroid
          ? MethodChannelLocalNotifications()
          :
          // TODO: Missing implementation
          LocalNotificationsEmpty();

  /// The default instance of [LocalNotificationsPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalNotifications].
  static LocalNotificationsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalNotificationsPlatform] when
  /// they register themselves.
  static set instance(LocalNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
