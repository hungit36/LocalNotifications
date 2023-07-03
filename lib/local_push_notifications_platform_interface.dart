import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_push_notifications_method_channel.dart';

abstract class LocalPushNotificationsPlatform extends PlatformInterface {
  /// Constructs a LocalPushNotificationsPlatform.
  LocalPushNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalPushNotificationsPlatform _instance = MethodChannelLocalPushNotifications();

  /// The default instance of [LocalPushNotificationsPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalPushNotifications].
  static LocalPushNotificationsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalPushNotificationsPlatform] when
  /// they register themselves.
  static set instance(LocalPushNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
