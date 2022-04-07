# loplat_plengi

loplat plengi(Place Engine) SDK plugin project.

## Supported platforms

* Flutter Android
* Flutter iOS

|             | Android | iOS  | Linux | macOS  | Web | Windows     |
|-------------|---------|------|-------|--------|-----|-------------|
| **Support** | SDK 16+ | 9.0+ |   -   |    -   |  -  |      -      |

## Usage
To use this plugin, add `loplat_plengi` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### Examples
Here are small examples that show you how to use the API.

#### Recieve location data
To see detail location data, please visit [loplat developer site](https://developers.loplat.com/android/#_2).

```dart
import 'dart:isolate';
import 'dart:ui';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

Future<void> main() async {
  /// Register the UI isolate's SendPort to allow for communication from the background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static SendPort? uiSendPort;

  @override
  void initState() {
    super.initState();
    /// Listen location infomations from background
    LoplatPlengiPlugin.setListener(callback);
    initPlatformState();
  }

  // The callback for loplat plegni, msg is JSON String.
  static Future<bool> callback(String msg) async {
    print('result: $msg');

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
    return true;
  }
}
```

