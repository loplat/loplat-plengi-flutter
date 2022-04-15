# loplat_plengi
loplat plengi(Place Engine) SDK plugin project.

## Supported platforms
* Flutter Android(plengi v2.1.1.3.1)
* Flutter iOS(MiniPlengi v1.4.2.2)

|             | Android | iOS  |
|-------------|---------|------|
| **Support** | SDK 16+ | 9.0+ |

## Usage
To use this plugin, add `loplat_plengi` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Examples
Here are small examples that show you how to use the API.

#### Receive location data
To see detail location data, please visit [loplat developer site](https://developers.loplat.com/android/#_2).
```dart
import 'dart:isolate';
import 'dart:ui';
import 'dart:convert';
import 'package:loplat_plengi/loplat_plengi.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// The background port
SendPort? uiSendPort;

/// The callback for loplat plengi
Future<bool> callback(String msg) async {
  String locationInfo = getLocationInfo(msg);
  print('result: $locationInfo');

  // This will be null if we're running in the background.
  uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
  uiSendPort?.send(null);
  return true;
}

String getLocationInfo(String log) {
  if (log.isEmpty) {
    return '';
  }
  Map<String,dynamic> jsonData = jsonDecode(log);
  String inNear = '';
  String locationInfo = '';
  if (jsonData['place'] != null) {
    if (jsonData['place']['accuracy'] >= jsonData['place']['threshold']) {
      inNear = '[IN]';
    } else {
      inNear = '[NEAR]';
    }
    locationInfo += '  $inNear${jsonData['place']['name']},'
        '${jsonData['place']['tags']}(${jsonData['place']['loplat_id']}),'
        '${jsonData['place']['floor']}F,${jsonData['place']['accuracy']}/${jsonData['place']['threshold']}';
  }
  if (jsonData['complex'] != null) {
    locationInfo += '\n  [${jsonData['complex']['id']}]${jsonData['complex']['name']}';
  }
  if (jsonData['area'] != null) {
    locationInfo += '\n  [${jsonData['area']['id']}]${jsonData['area']['tag']},${jsonData['area']['name']}';
  }
  if (jsonData['district'] != null) {
    locationInfo += '\n  ${jsonData['district']['lv1_name']} ${jsonData['district']['lv2_name']} ${jsonData['district']['lv3_name']}';
  }
  if (jsonData['location'] != null) {
    locationInfo += '\n  ${jsonData['location']['lat']}, ${jsonData['location']['lng']}';
  }
  if (jsonData['ad'] != null) {
    locationInfo += '\n  ${jsonData['ad']['campaign_id']}, ${jsonData['ad']['title']}, ${jsonData['ad']['body']}';
  }
  return locationInfo;
}

Future<void> main() async {
  /// Register the UI isolate's SendPort to allow for communication from the background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  runApp(const MyApp());

  /// After runApp, register callback
  LoplatPlengiPlugin.setListener(callback);
}
```

