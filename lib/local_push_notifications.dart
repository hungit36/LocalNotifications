
import 'local_push_notifications_platform_interface.dart';

class LocalPushNotifications {
  Future<String?> getPlatformVersion() {
    return LocalPushNotificationsPlatform.instance.getPlatformVersion();
  }
}
