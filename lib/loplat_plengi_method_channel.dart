import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'loplat_plengi_platform_interface.dart';

/// An implementation of [LoplatPlengiPlatform] that uses method channels.
class MethodChannelLoplatPlengi extends LoplatPlengiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('loplat_plengi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
