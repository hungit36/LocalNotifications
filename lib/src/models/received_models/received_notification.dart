import 'package:local_push_notifications/src/models/base_notification_content.dart';

import '../../definitions.dart';
import '../../enumerators/notification_life_cycle.dart';
import '../../enumerators/notification_source.dart';
import '../../utils/assert_utils.dart';
import '../../utils/date_utils.dart';

/// All received details of a notification created or displayed on the system
/// The data field
class ReceivedNotification extends BaseNotificationContent {
  @override
  ReceivedNotification fromMap(Map<String, dynamic> mapData) {
    super.fromMap(mapData);

    createdDate = LocalAssertUtils.extractValue(
        NOTIFICATION_CREATED_DATE, mapData, DateTime);

    displayedDate = LocalAssertUtils.extractValue(
        NOTIFICATION_DISPLAYED_DATE, mapData, DateTime);

    createdSource = LocalAssertUtils.extractEnum<NotificationSource>(
        NOTIFICATION_CREATED_SOURCE, mapData, NotificationSource.values);

    createdLifeCycle = LocalAssertUtils.extractEnum<NotificationLifeCycle>(
        NOTIFICATION_CREATED_LIFECYCLE, mapData, NotificationLifeCycle.values);

    displayedLifeCycle = LocalAssertUtils.extractEnum<NotificationLifeCycle>(
        NOTIFICATION_DISPLAYED_LIFECYCLE,
        mapData,
        NotificationLifeCycle.values);

    return this;
  }

  /// Exports all content into a serializable object
  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    return map
      ..addAll({
        NOTIFICATION_CREATED_SOURCE: createdSource?.name,
        NOTIFICATION_CREATED_LIFECYCLE: createdLifeCycle?.name,
        NOTIFICATION_DISPLAYED_LIFECYCLE: displayedLifeCycle?.name,
        NOTIFICATION_CREATED_DATE:
            LocalDateUtils.parseDateToString(createdDate),
        NOTIFICATION_DISPLAYED_DATE:
            LocalDateUtils.parseDateToString(displayedDate),
      });
  }
}
