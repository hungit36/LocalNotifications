import 'package:local_push_notifications/src/utils/media_abstract_utils.dart'
    if (dart.library.html) 'package:local_push_notifications/src/utils/media_abstract_utils_web.dart';
import 'package:flutter/material.dart';

class LocalAudioUtils extends LocalMediaUtils {
  /// FACTORY METHODS *********************************************

  factory LocalAudioUtils() => _instance;

  @visibleForTesting
  LocalAudioUtils.private();

  static final LocalAudioUtils _instance = LocalAudioUtils.private();

  /// FACTORY METHODS *********************************************

  @override
  getFromMediaAsset(String mediaPath) {
    return null;

    /// TODO MISSING IMPLEMENTATION
  }

  @override
  getFromMediaFile(String mediaPath) {
    return null;

    /// TODO MISSING IMPLEMENTATION
  }

  @override
  getFromMediaNetwork(String mediaPath) {
    return null;

    /// TODO MISSING IMPLEMENTATION
  }

  @override
  getFromMediaResource(String mediaPath) {
    return null;

    /// TODO MISSING IMPLEMENTATION
    /*
        String cleanPath = BitmapUtils.cleanMediaPath(mediaPath);
        rootBundle.loadString(cleanPath).then((value){
          print(value);
        });
        break;
        */
  }
}
