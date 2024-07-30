import 'package:flutter_test/flutter_test.dart';
import 'package:loplat_plengi/loplat_plengi.dart';
import 'package:loplat_plengi/loplat_plengi_platform_interface.dart';
import 'package:loplat_plengi/loplat_plengi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLoplatPlengiPlatform
    with MockPlatformInterfaceMixin
    implements LoplatPlengiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LoplatPlengiPlatform initialPlatform = LoplatPlengiPlatform.instance;

  test('$MethodChannelLoplatPlengi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLoplatPlengi>());
  });

  test('getPlatformVersion', () async {
    //LoplatPlengiPlugin loplatPlengiPlugin = LoplatPlengiPlugin();
    MockLoplatPlengiPlatform fakePlatform = MockLoplatPlengiPlatform();
    LoplatPlengiPlatform.instance = fakePlatform;

    expect(await LoplatPlengiPlugin.getPlatformVersion, '42');
  });
}
