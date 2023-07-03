import 'package:local_push_notifications/src/utils/media_abstract_utils.dart'
    if (dart.library.html) 'package:local_push_notifications/src/utils/media_abstract_utils_web.dart';
import 'package:local_push_notifications/src/utils/resource_image_provider.dart';
import 'package:flutter/material.dart';

class LocalBitmapUtils extends LocalMediaUtils {
  /// FACTORY METHODS *********************************************

  factory LocalBitmapUtils() => _instance;

  @visibleForTesting
  LocalBitmapUtils.private();

  static final LocalBitmapUtils _instance = LocalBitmapUtils.private();

  /// FACTORY METHODS *********************************************

  @override
  ImageProvider getFromMediaAsset(String mediaPath) {
    return AssetImage(cleanMediaPath(mediaPath));
  }

  @override
  ImageProvider getFromMediaNetwork(String mediaPath) {
    return NetworkImage(mediaPath);
  }

  @override
  ImageProvider getFromMediaResource(String mediaPath) {
    return ResourceImage(mediaPath);
  }
}
