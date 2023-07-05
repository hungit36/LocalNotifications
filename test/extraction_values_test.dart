import 'package:local_push_notifications/local_notifications.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {});

  test('extractValueTest', () async {
    expect("title", LocalAssertUtils.extractValue("test", {"test": "title"}, String));
    expect(" title", LocalAssertUtils.extractValue("test", {"test": " title"}, String));
    expect("", LocalAssertUtils.extractValue("test", {"test": ""}, String));
    expect(" ", LocalAssertUtils.extractValue("test", {"test": " "}, String));

    expect(10, LocalAssertUtils.extractValue("test", {"test": "10"}, int));
    expect(10, LocalAssertUtils.extractValue("test", {"test": 10}, int));
    expect(10, LocalAssertUtils.extractValue("test", {"test": "10.0"}, int));
    expect(10.0, LocalAssertUtils.extractValue("test", {"test": "10.0"}, double));
    expect(0, LocalAssertUtils.extractValue("test", {"test": "0"}, int));
    expect(0.0, LocalAssertUtils.extractValue("test", {"test": "0"}, double));
    expect(0, LocalAssertUtils.extractValue("test", {"test": "0.0"}, int));
    expect(0, LocalAssertUtils.extractValue("test", {"test": 0}, int));

    expect(0xFFFF0000, LocalAssertUtils.extractValue("test", {"test": "#FF0000"}, int));
    expect(0xFFFF0000, LocalAssertUtils.extractValue("test", {"test": "#ff0000"}, int));
    expect(0xFFFF0000, LocalAssertUtils.extractValue("test", {"test": "#FFFF0000"}, int));
    expect(0x00FF0000, LocalAssertUtils.extractValue("test", {"test": "#00FF0000"}, int));
    expect(0xFFFF0000, LocalAssertUtils.extractValue("test", {"test": "0xFF0000"}, int));
    expect(0xFFFF0000, LocalAssertUtils.extractValue("test", {"test": "0xFFff0000"}, int));

    expect(Colors.black, LocalAssertUtils.extractValue("test", {"test": "#000000"}, Color));
    expect(Colors.black, LocalAssertUtils.extractValue("test", {"test": "#FF000000"}, Color));
    expect(Colors.transparent, LocalAssertUtils.extractValue("test", {"test": "#00000000"}, Color));

    expect(null, LocalAssertUtils.extractValue("test", {"test": null}, Color));
    expect(null, LocalAssertUtils.extractValue("test", {"test": "#0004"}, Color));
    expect(null, LocalAssertUtils.extractValue("test", {"test": "#04"}, Color));
    expect(null, LocalAssertUtils.extractValue("test", {"test": " "}, Color));

    expect(null, LocalAssertUtils.extractValue("test", {"test": null}, int));
    expect(null, LocalAssertUtils.extractValue("test", {"test": ""}, int));
    expect(null, LocalAssertUtils.extractValue("test", {"test": " "}, int));

    expect(null, LocalAssertUtils.extractValue("test", {"test": 0}, String));
    expect(null, LocalAssertUtils.extractValue("test", {"test": null}, String));

    expect(true, LocalAssertUtils.extractValue("test", {"test": true}, bool));
    expect(true, LocalAssertUtils.extractValue("test", {"test": "true"}, bool));
    expect(false, LocalAssertUtils.extractValue("test", {"test": "false"}, bool));
  });

  test('extractEnumTest', () async {
    expect(NotificationPrivacy.Private,
        LocalAssertUtils.extractEnum<NotificationPrivacy>(
            "test", {"test": "Private"}, NotificationPrivacy.values));

    expect(NotificationPrivacy.Public,
        LocalAssertUtils.extractEnum<NotificationPrivacy>(
            "test", {"test": "Public"}, NotificationPrivacy.values));

    expect(null,
        LocalAssertUtils.extractEnum<NotificationPrivacy>(
            "test", {"test": ""}, NotificationPrivacy.values));

    expect(null,
        LocalAssertUtils.extractEnum<NotificationPrivacy>(
            "test", {"test": " "}, NotificationPrivacy.values));

    expect(null,
        LocalAssertUtils.extractEnum<NotificationPrivacy>(
            "test", {"test": null}, NotificationPrivacy.values));
  });
}
