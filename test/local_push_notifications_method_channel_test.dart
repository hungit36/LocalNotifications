import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_push_notifications/local_notifications_method_channel.dart';

void main() {
  MethodChannelLocalNotifications platform = MethodChannelLocalNotifications();
  const MethodChannel channel = MethodChannel('local_push_notifications');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await platform.getPlatformVersion(), '42');
  });
}
