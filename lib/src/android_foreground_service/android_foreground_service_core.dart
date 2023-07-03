import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../definitions.dart';
import '../enumerators/foreground_start_mode.dart';
import '../enumerators/foreground_service_type.dart';
import '../enumerators/android_foreground_service_constants.dart';
import '../models/notification_button.dart';
import '../models/notification_content.dart';
import '../models/notification_model.dart';
import '../utils/assert_utils.dart';

/// Static helper class that provides methods to start and stop a foreground service.
///
/// On any platform other than Android, all methods in this class are no-ops and do nothing,
/// so it is safe to call them without a platform check.
class AndroidForegroundService {
  static const MethodChannel _channel = MethodChannel(CHANNEL_FLUTTER_PLUGIN);

  @Deprecated(
      "This method is deprecated. You should use startAndroidForegroundService instead.")
  static Future<void> startForeground(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons,
      int startType = AndroidForegroundServiceConstants.startSticky,
      int? foregroundServiceType}) async {
    if (Platform.isAndroid) {
      startAndroidForegroundService(
        content: content,
        actionButtons: actionButtons,
        foregroundStartMode:
            AndroidForegroundServiceConstants.startModeFromAndroidValues(
                startType),
        foregroundServiceType:
            AndroidForegroundServiceConstants.serviceTypeFromAndroidValues(
                foregroundServiceType ?? 0),
      );
    }
  }

  static Future<void> startAndroidForegroundService(
      {required NotificationContent content,
      List<NotificationActionButton>? actionButtons,
      ForegroundStartMode foregroundStartMode = ForegroundStartMode.stick,
      ForegroundServiceType foregroundServiceType =
          ForegroundServiceType.none}) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod(CHANNEL_METHOD_START_FOREGROUND, {
        FOREGROUND_NOTIFICATION_MODEL:
            NotificationModel(content: content, actionButtons: actionButtons)
                .toMap(),
        FOREGROUND_START_MODE:
            LocalAssertUtils.toSimpleEnumString(foregroundStartMode),
        FOREGROUND_SERVICE_TYPE:
            LocalAssertUtils.toSimpleEnumString(foregroundServiceType)
      });
    }
  }

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
    if (Platform.isAndroid) {
      await _channel
          .invokeMethod(CHANNEL_METHOD_STOP_FOREGROUND, {NOTIFICATION_ID: id});
    }
  }

  /// The constructor is hidden since this class should not be instantiated.
  const AndroidForegroundService._();
}
