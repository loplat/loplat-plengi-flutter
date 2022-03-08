import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loplat_plengi/loplat_plengi.dart';

void main() {
  const MethodChannel channel = MethodChannel('loplat_plengi');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LoplatPlengiPlugin.platformVersion, '42');
  });
}
