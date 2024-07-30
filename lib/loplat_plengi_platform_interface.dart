import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'loplat_plengi_method_channel.dart';

abstract class LoplatPlengiPlatform extends PlatformInterface {
  /// Constructs a LoplatPlengiPlatform.
  LoplatPlengiPlatform() : super(token: _token);

  static final Object _token = Object();

  static LoplatPlengiPlatform _instance = MethodChannelLoplatPlengi();

  /// The default instance of [LoplatPlengiPlatform] to use.
  ///
  /// Defaults to [MethodChannelLoplatPlengi].
  static LoplatPlengiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LoplatPlengiPlatform] when
  /// they register themselves.
  static set instance(LoplatPlengiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
