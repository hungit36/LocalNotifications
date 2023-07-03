import '../../android_foreground_service.dart';
import '../models/notification_button.dart';
import '../models/notification_content.dart';

/// Static helper class that provides methods to start and stop a foreground service.
///
/// On any platform other than Android, all methods in this class are no-ops and do nothing,
/// so it is safe to call them without a platform check.
class AndroidForegroundService {
  
  @Deprecated(
      "This method is deprecated. You should use startAndroidForegroundService instead.")
  static Future<void> startForeground(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons,
      int startType = AndroidForegroundServiceConstants.startSticky,
      int? foregroundServiceType}) async {
    //no-op on web
  }

  static Future<void> startAndroidForegroundService(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons,
      ForegroundStartMode foregroundStartMode = ForegroundStartMode.stick,
      ForegroundServiceType foregroundServiceType =
          ForegroundServiceType.none}) async {}

  /// Stops a foreground service.
  ///
  /// If the foreground service was not started, this function
  /// will do nothing.
  ///
  /// It is sufficient to call this method once to stop the
  /// foreground service, even if [startAndroidForegroundService] was called
  /// multiple times.
  ///
  /// On any platform other than Android, this is a no-op and does nothing,
  /// so it is safe to call it without a platform check.
  static Future<void> stopForeground(int id) async {
    //no-op on web
  }

  /// The constructor is hidden since this class should not be instantiated.
  const AndroidForegroundService._();
}
