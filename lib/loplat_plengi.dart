import 'dart:async';

import 'package:flutter/services.dart';

class LoplatPlengiPlugin {
  static const MethodChannel _channel =
      MethodChannel('loplat_plengi');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> get getEngineStatus async {
    final int status = await _channel.invokeMethod('getEngineStatus');
    return status;
  }

  static Future<int?> start(String id, String pw) async {
    final int? status = await _channel.invokeMethod('start', [id, pw]);
    return status;
  }

  static Future<int?> get stop async {
    final int? status = await _channel.invokeMethod('stop');
    return status;
  }

  static Future<String?> setEchoCode(String code) async {
    final String? status = await _channel.invokeMethod('setEchoCode', [code]);
    return status;
  }

  static Future<String?> enableAdNetwork(
      bool enableAd, bool enableAdNoti) async {
    final String? status = await _channel
        .invokeMethod('enableAdNetwork', [enableAd, enableAdNoti]);
    return status;
  }

  static Future<String?> enableTestServer(bool value) async {
    final String? status =
        await _channel.invokeMethod('enableTestServer', [value]);
    return status;
  }

  static Future<int?> getTestServerMode() async {
    final int? status = await _channel.invokeMethod('getTestServerMode');
    return status;
  }

  static Future<String?> testRefreshPlaceForeground() async {
    final String? res =
        await _channel.invokeMethod('TEST_refreshPlace_foreground');
    return res;
  }

  static Future<String?> requestAlwaysAuthorization() async {
        final String? res = await _channel.invokeMethod("requestAlwaysAuthorization");
        return res;
  }
}
