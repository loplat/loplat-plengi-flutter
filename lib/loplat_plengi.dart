import 'dart:async';

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _backgroundName = 'com.loplat.plengi/background';

// This is the entrypoint for the background isolate. Since we can only enter
// an isolate once, we setup a MethodChannel to listen for method invocations
// from the native portion of the plugin. This allows for the plugin to perform
// any necessary processing in Dart (e.g., populating a custom object) before
// invoking the provided callback.
void _plengiCallbackDispatcher() {
  // Initialize state necessary for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  const _channel = MethodChannel(_backgroundName, JSONMethodCodec());
  // This is where the magic happens and we handle background events from the
  // native portion of the plugin.
  _channel.setMethodCallHandler((MethodCall call) async {
    final dynamic args = call.arguments;
    final handle = CallbackHandle.fromRawHandle(args[0]);

    // PluginUtilities.getCallbackFromHandle performs a lookup based on the
    // callback handle and returns a tear-off of the original callback.
    final closure = PluginUtilities.getCallbackFromHandle(handle);

    if (closure == null) {
      developer.log('Fatal: could not find callback');
      exit(-1);
    }

    // ignore: inference_failure_on_function_return_type
    if (closure is Function()) {
      closure();
      // ignore: inference_failure_on_function_return_type
    } else if (closure is Function(int)) {
      final int id = args[1];
      closure(id);
    } else if (closure is Function(String)) {
      final String msg = args[1];
      closure(msg);
    }
    /// parameter 가 변경되면 추가
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling alarms.
  _channel.invokeMethod<void>('plengi.initialized');
}

// A lambda that gets the handle for the given [callback].
typedef _GetCallbackHandle = CallbackHandle? Function(Function callback);

class LoplatPlengiPlugin {
  static const MethodChannel _channel =
      MethodChannel('loplat_plengi');

  // Callback used to get the handle for a callback. It's
  // [PluginUtilities.getCallbackHandle] by default.
  // ignore: prefer_function_declarations_over_variables
  static final _GetCallbackHandle _getCallbackHandle =
      (Function callback) => PluginUtilities.getCallbackHandle(callback);

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> get getEngineStatus async {
    final int status = await _channel.invokeMethod('getEngineStatus');
    return status;
  }

  static Future<bool> startBgMethodChannel() async {
    final handle = _getCallbackHandle(_plengiCallbackDispatcher);
    if (handle == null) {
      return false;
    }
    final status = await _channel.invokeMethod<bool>('PlengiListener.start', [handle.toRawHandle()]);
    return status ?? false;
  }

  static Future<bool> setListener(Function callback) async {
    startBgMethodChannel();
    int? handleId = 0;
    if (callback is Function(int) || callback is Function(String)) {
      final handle = _getCallbackHandle(callback);
      handleId = handle?.toRawHandle();
    }
    final status = await _channel.invokeMethod<bool>('setListener', [handleId]);
    return status ?? false;
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
      bool enableAd, {bool enableAdNoti=true}) async {
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
