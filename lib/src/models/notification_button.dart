import 'dart:ui';
import 'dart:developer' as developer;

import 'package:local_push_notifications/src/definitions.dart';
import 'package:local_push_notifications/src/enumerators/action_type.dart';
import 'package:local_push_notifications/src/enumerators/media_source.dart';
import 'package:local_push_notifications/src/exceptions/local_exception.dart';
import 'package:local_push_notifications/src/models/model.dart';
import 'package:local_push_notifications/src/utils/assert_utils.dart';
import 'package:local_push_notifications/src/utils/bitmap_utils.dart';
import 'package:local_push_notifications/src/utils/string_utils.dart';

/// Notification button to display inside a notification.
/// Since Android 7, icons are displayed only for Media Layout Notifications
/// [icon] must be a native resource media type
class NotificationActionButton extends Model {
  String? _key;
  String? _label;
  String? _icon;
  bool? _enabled;
  bool _requireInputText;
  bool? _autoDismissible;
  bool? _showInCompactView;
  bool? _isDangerousOption;
  Color? _color;
  ActionType? _actionType;

  String? get key {
    return _key;
  }

  String? get label {
    return _label;
  }

  String? get icon {
    return _icon;
  }

  bool? get enabled {
    return _enabled;
  }

  bool get requireInputText {
    return _requireInputText;
  }

  bool? get autoDismissible {
    return _autoDismissible;
  }

  bool? get showInCompactView {
    return _showInCompactView;
  }

  bool? get isDangerousOption {
    return _isDangerousOption;
  }

  Color? get color {
    return _color;
  }

  ActionType? get actionType {
    return _actionType;
  }

  NotificationActionButton(
      {required String key,
      required String label,
      String? icon,
      bool enabled = true,
      bool requireInputText = false,
      bool autoDismissible = true,
      bool showInCompactView = false,
      bool isDangerousOption = false,
      Color? color,
      ActionType actionType = ActionType.Default})
      : _key = key,
        _label = label,
        _icon = icon,
        _enabled = enabled,
        _requireInputText = requireInputText,
        _autoDismissible = autoDismissible,
        _showInCompactView = showInCompactView,
        _isDangerousOption = isDangerousOption,
        _color = color,
        _actionType = actionType {
    // Adapting input type to 0.7.0 pattern
    _adaptInputFieldToRequireText();
  }

  @override
  NotificationActionButton? fromMap(Map<String, dynamic> mapData) {
    _processRetroCompatibility(mapData);
    _key = LocalAssertUtils.extractValue(NOTIFICATION_KEY, mapData, String);
    _icon = LocalAssertUtils.extractValue(NOTIFICATION_ICON, mapData, String);
    _label = LocalAssertUtils.extractValue(
        NOTIFICATION_BUTTON_LABEL, mapData, String);
    _enabled =
        LocalAssertUtils.extractValue(NOTIFICATION_ENABLED, mapData, bool);
    _requireInputText = LocalAssertUtils.extractValue(
        NOTIFICATION_REQUIRE_INPUT_TEXT, mapData, bool);
    _autoDismissible = LocalAssertUtils.extractValue(
        NOTIFICATION_AUTO_DISMISSIBLE, mapData, bool);
    _showInCompactView = LocalAssertUtils.extractValue(
        NOTIFICATION_SHOW_IN_COMPACT_VIEW, mapData, bool);
    _isDangerousOption = LocalAssertUtils.extractValue(
        NOTIFICATION_IS_DANGEROUS_OPTION, mapData, bool);
    _actionType = LocalAssertUtils.extractEnum<ActionType>(
        NOTIFICATION_ACTION_TYPE, mapData, ActionType.values);

    _color =
        LocalAssertUtils.extractValue(NOTIFICATION_COLOR, mapData, Color);

    return this;
  }

  void _processRetroCompatibility(Map<String, dynamic> dataMap) {
    if (dataMap.containsKey("autoCancel")) {
      developer
          .log("autoCancel is deprecated. Please use autoDismissible instead.");
      _autoDismissible =
          LocalAssertUtils.extractValue("autoCancel", dataMap, bool);
    }

    if (dataMap.containsKey("buttonType")) {
      developer.log("buttonType is deprecated. Please use actionType instead.");
      _actionType = LocalAssertUtils.extractEnum<ActionType>(
          "buttonType", dataMap, ActionType.values);
    }

    _adaptInputFieldToRequireText();
  }

  void _adaptInputFieldToRequireText() {
    // ignore: deprecated_member_use_from_same_package
    if (_actionType == ActionType.InputField) {
      developer.log(
          "InputField is deprecated. Please use requireInputText instead.");
      _requireInputText = true;
      _actionType = ActionType.SilentAction;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    _adaptInputFieldToRequireText();

    return {
      NOTIFICATION_KEY: _key,
      NOTIFICATION_ICON: _icon,
      NOTIFICATION_BUTTON_LABEL: _label,
      NOTIFICATION_ENABLED: _enabled,
      NOTIFICATION_REQUIRE_INPUT_TEXT: _requireInputText,
      NOTIFICATION_AUTO_DISMISSIBLE: _autoDismissible,
      NOTIFICATION_SHOW_IN_COMPACT_VIEW: _showInCompactView,
      NOTIFICATION_IS_DANGEROUS_OPTION: _isDangerousOption,
      NOTIFICATION_ACTION_TYPE: _actionType?.name,
      NOTIFICATION_COLOR: _color?.value
    };
  }

  @override
  void validate() {
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_key, String)) {
      throw const LocalNotificationsException(message: 'key id is requried');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_label, String)) {
      throw const LocalNotificationsException(
          message: 'label id is requried');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_autoDismissible, bool)) {
      throw const LocalNotificationsException(
          message: 'autoDismissible id is requried');
    }
    if (LocalAssertUtils.isNullOrEmptyOrInvalid(_showInCompactView, bool)) {
      throw const LocalNotificationsException(
          message: 'showInCompactView id is requried');
    }

    // For action buttons, it's only allowed resource media types
    if (!LocalStringUtils.isNullOrEmpty(_icon) &&
        LocalBitmapUtils().getMediaSource(_icon!) != MediaSource.Resource) {
      throw const LocalNotificationsException(
          message:
              'icons for action buttons must be a native resource media type');
    }
  }
}
