import 'package:local_push_notifications/src/definitions.dart';
import 'package:local_push_notifications/src/exceptions/local_exception.dart';
import 'package:local_push_notifications/src/models/model.dart';
import 'package:local_push_notifications/src/utils/assert_utils.dart';

class NotificationChannelGroup extends Model {
  String? _channelGroupKey;
  String? _channelGroupName;

  String? get channelGroupKey {
    return _channelGroupKey;
  }

  String? get channelGroupName {
    return _channelGroupName;
  }

  NotificationChannelGroup(
      {required String channelGroupKey, required String channelGroupName}) {
    _channelGroupKey = channelGroupKey;
    _channelGroupName = channelGroupName;
  }

  @override
  NotificationChannelGroup? fromMap(Map<String, dynamic> mapData) {
    _channelGroupKey = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_GROUP_KEY, mapData, String);
    _channelGroupName = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_GROUP_NAME, mapData, String);

    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      NOTIFICATION_CHANNEL_GROUP_KEY: _channelGroupKey,
      NOTIFICATION_CHANNEL_GROUP_NAME: _channelGroupName
    };
  }

  @override
  void validate() {
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_channelGroupKey, String)) {
      throw const LocalNotificationsException(
          message: 'channelGroupKey is required');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_channelGroupName, String)) {
      throw const LocalNotificationsException(
          message: 'channelGroupName is required');
    }
  }
}
