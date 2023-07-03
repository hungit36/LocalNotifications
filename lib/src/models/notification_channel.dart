import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../definitions.dart';
import '../enumerators/default_ringtone_type.dart';
import '../enumerators/group_alert_behaviour.dart';
import '../enumerators/group_sort.dart';
import '../enumerators/media_source.dart';
import '../enumerators/notification_importance.dart';
import '../enumerators/notification_privacy.dart';
import '../exceptions/local_exception.dart';
import '../utils/assert_utils.dart';
import '../utils/bitmap_utils.dart';
import '../utils/string_utils.dart';
import 'model.dart';

/// A representation of default settings that applies to all notifications with same channel key
/// [soundSource] needs to be a native resource media type
class NotificationChannel extends Model {
  String? channelKey;
  String? channelName;
  String? channelDescription;
  bool? channelShowBadge;

  String? channelGroupKey;

  NotificationImportance? importance;

  bool? playSound;
  String? soundSource;
  DefaultRingtoneType? defaultRingtoneType;

  bool? enableVibration;
  Int64List? vibrationPattern;

  bool? enableLights;
  Color? ledColor;
  int? ledOnMs;
  int? ledOffMs;

  String? groupKey;
  GroupSort? groupSort;
  GroupAlertBehavior? groupAlertBehavior;

  NotificationPrivacy? defaultPrivacy;

  String? icon;
  Color? defaultColor;

  bool? locked;
  bool? onlyAlertOnce;
  bool? stayOnScreen = true;

  bool? criticalAlerts;

  NotificationChannel(
      {required this.channelKey,
      required this.channelName,
      required this.channelDescription,
      this.channelGroupKey,
      this.channelShowBadge,
      this.importance,
      this.playSound,
      this.soundSource,
      this.defaultRingtoneType,
      this.enableVibration,
      this.vibrationPattern,
      this.enableLights,
      this.ledColor,
      this.ledOnMs,
      this.ledOffMs,
      this.groupKey,
      this.groupSort,
      this.groupAlertBehavior,
      this.icon,
      this.defaultColor,
      this.locked,
      this.onlyAlertOnce,
      this.defaultPrivacy,
      this.criticalAlerts})
      : super() {
    channelKey = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_KEY, channelKey, String);
    channelName = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_NAME, channelName, String);
    channelDescription = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_DESCRIPTION, channelDescription, String);
    channelShowBadge = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_SHOW_BADGE, channelShowBadge, bool);

    channelGroupKey = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_GROUP_KEY, channelGroupKey, String);

    importance = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_IMPORTANCE, importance, NotificationImportance);
    playSound = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_PLAY_SOUND, playSound, bool);
    criticalAlerts = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_CHANNEL_CRITICAL_ALERTS, criticalAlerts, bool);
    soundSource = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_SOUND_SOURCE, soundSource, String);
    enableVibration = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_ENABLE_VIBRATION, enableVibration, bool);
    vibrationPattern = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_VIBRATION_PATTERN, vibrationPattern, Int64List);
    enableLights = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_ENABLE_LIGHTS, enableLights, bool);
    ledColor = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_LED_COLOR, ledColor, Color);
    ledOnMs = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_LED_ON_MS, ledOnMs, int);
    ledOffMs = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_LED_OFF_MS, ledOffMs, int);
    groupKey = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_GROUP_KEY, groupKey, String);
    groupSort = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_GROUP_SORT, groupSort, GroupSort);
    groupAlertBehavior = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_GROUP_ALERT_BEHAVIOR,
        groupAlertBehavior,
        GroupAlertBehavior);
    icon =
        LocalAssertUtils.getValueOrDefault(NOTIFICATION_ICON, icon, String);
    defaultColor = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_DEFAULT_COLOR, defaultColor, Color);
    locked =
        LocalAssertUtils.getValueOrDefault(NOTIFICATION_LOCKED, locked, bool);
    onlyAlertOnce = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_ONLY_ALERT_ONCE, onlyAlertOnce, bool);
    defaultPrivacy = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_DEFAULT_PRIVACY, defaultPrivacy, NotificationPrivacy);
    defaultRingtoneType = LocalAssertUtils.getValueOrDefault(
        NOTIFICATION_DEFAULT_RINGTONE_TYPE,
        defaultRingtoneType,
        DefaultRingtoneType);

    // For small icons, it's only allowed resource media types
    assert(LocalStringUtils.isNullOrEmpty(icon) ||
        LocalBitmapUtils().getMediaSource(icon!) == MediaSource.Resource);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      NOTIFICATION_ICON: icon,
      NOTIFICATION_CHANNEL_KEY: channelKey,
      NOTIFICATION_CHANNEL_NAME: channelName,
      NOTIFICATION_CHANNEL_DESCRIPTION: channelDescription,
      NOTIFICATION_CHANNEL_GROUP_KEY: channelGroupKey,
      NOTIFICATION_CHANNEL_SHOW_BADGE: channelShowBadge,
      NOTIFICATION_PLAY_SOUND: playSound,
      NOTIFICATION_SOUND_SOURCE: soundSource,
      NOTIFICATION_ENABLE_VIBRATION: enableVibration,
      NOTIFICATION_VIBRATION_PATTERN: vibrationPattern,
      NOTIFICATION_ENABLE_LIGHTS: enableLights,
      NOTIFICATION_DEFAULT_COLOR: defaultColor?.value,
      NOTIFICATION_LED_COLOR: ledColor?.value,
      NOTIFICATION_LED_ON_MS: ledOnMs,
      NOTIFICATION_LED_OFF_MS: ledOffMs,
      NOTIFICATION_GROUP_KEY: groupKey,
      NOTIFICATION_GROUP_SORT: groupSort?.name,
      NOTIFICATION_GROUP_ALERT_BEHAVIOR: groupAlertBehavior?.name,
      NOTIFICATION_DEFAULT_PRIVACY: defaultPrivacy?.name,
      NOTIFICATION_IMPORTANCE: importance?.name,
      NOTIFICATION_DEFAULT_RINGTONE_TYPE: defaultRingtoneType?.name,
      NOTIFICATION_LOCKED: locked,
      NOTIFICATION_CHANNEL_CRITICAL_ALERTS: criticalAlerts,
      NOTIFICATION_ONLY_ALERT_ONCE: onlyAlertOnce
    };
  }

  @override
  NotificationChannel fromMap(Map<String, dynamic> mapData) {
    channelKey = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_KEY, mapData, String);
    channelName = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_NAME, mapData, String);
    channelDescription = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_DESCRIPTION, mapData, String);
    channelShowBadge = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_SHOW_BADGE, mapData, bool);

    channelGroupKey = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_GROUP_KEY, mapData, String);

    playSound =
        LocalAssertUtils.extractValue(NOTIFICATION_PLAY_SOUND, mapData, bool);
    soundSource = LocalAssertUtils.extractValue(
        NOTIFICATION_SOUND_SOURCE, mapData, String);

    enableVibration = LocalAssertUtils.extractValue(
        NOTIFICATION_ENABLE_VIBRATION, mapData, bool);
    vibrationPattern = LocalAssertUtils.extractValue(
        NOTIFICATION_VIBRATION_PATTERN, mapData, Int64List);
    enableLights = LocalAssertUtils.extractValue(
        NOTIFICATION_ENABLE_LIGHTS, mapData, bool);

    importance = LocalAssertUtils.extractEnum<NotificationImportance>(
        NOTIFICATION_IMPORTANCE, mapData, NotificationImportance.values);
    defaultPrivacy = LocalAssertUtils.extractEnum<NotificationPrivacy>(
        NOTIFICATION_DEFAULT_PRIVACY, mapData, NotificationPrivacy.values);
    defaultRingtoneType = LocalAssertUtils.extractEnum<DefaultRingtoneType>(
        NOTIFICATION_DEFAULT_RINGTONE_TYPE,
        mapData,
        DefaultRingtoneType.values);

    groupKey = LocalAssertUtils.extractValue(
        NOTIFICATION_GROUP_KEY, mapData, String);
    groupSort = LocalAssertUtils.extractEnum<GroupSort>(
        NOTIFICATION_GROUP_SORT, mapData, GroupSort.values);
    groupAlertBehavior = LocalAssertUtils.extractEnum<GroupAlertBehavior>(
        NOTIFICATION_GROUP_ALERT_BEHAVIOR, mapData, GroupAlertBehavior.values);

    icon = LocalAssertUtils.extractValue(NOTIFICATION_ICON, mapData, String);
    locked =
        LocalAssertUtils.extractValue(NOTIFICATION_LOCKED, mapData, bool);
    onlyAlertOnce = LocalAssertUtils.extractValue(
        NOTIFICATION_ONLY_ALERT_ONCE, mapData, bool);

    defaultColor = LocalAssertUtils.extractValue(
        NOTIFICATION_DEFAULT_COLOR, mapData, Color);
    ledColor =
        LocalAssertUtils.extractValue(NOTIFICATION_LED_COLOR, mapData, Color);

    ledOnMs =
        LocalAssertUtils.extractValue(NOTIFICATION_LED_ON_MS, mapData, int);
    ledOffMs =
        LocalAssertUtils.extractValue(NOTIFICATION_LED_OFF_MS, mapData, int);

    criticalAlerts = LocalAssertUtils.extractValue(
        NOTIFICATION_CHANNEL_CRITICAL_ALERTS, mapData, bool);

    return this;
  }

  @override
  void validate() {
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(channelKey, String)) {
      throw const LocalNotificationsException(
          message: 'Property channelKey is requried');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(channelName, String)) {
      throw const LocalNotificationsException(
          message: 'Property channelName is requried');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(channelDescription, String)) {
      throw const LocalNotificationsException(
          message: 'Property channelDescription is requried');
    }
  }
}
