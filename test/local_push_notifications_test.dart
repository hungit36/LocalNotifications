import 'package:flutter_test/flutter_test.dart';
import 'package:local_push_notifications/local_push_notifications.dart';
import 'package:local_push_notifications/local_push_notifications_platform_interface.dart';
import 'package:local_push_notifications/local_push_notifications_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalPushNotificationsPlatform
    with MockPlatformInterfaceMixin
    implements LocalPushNotificationsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocalPushNotificationsPlatform initialPlatform = LocalPushNotificationsPlatform.instance;

  test('$MethodChannelLocalPushNotifications is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalPushNotifications>());
  });

  test('getPlatformVersion', () async {
    LocalPushNotifications localPushNotificationsPlugin = LocalPushNotifications();
    MockLocalPushNotificationsPlatform fakePlatform = MockLocalPushNotificationsPlatform();
    LocalPushNotificationsPlatform.instance = fakePlatform;

    expect(await localPushNotificationsPlugin.getPlatformVersion(), '42');
  });
}
