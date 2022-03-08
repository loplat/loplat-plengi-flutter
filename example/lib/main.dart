import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/services.dart';
import 'package:loplat_plengi/loplat_plengi.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _plengiStatus = "NOT_INITIALIZED";
  String _loplatResults = '';
  var getLocationButEnabled = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await Permission.locationWhenInUse.request().isGranted;
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      openAppSettings();
    }

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await LoplatPlengiPlugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    int engineStatus = await LoplatPlengiPlugin.getEngineStatus;
    String engineStatusStr = "NOT_INITIALIZED";
    if (engineStatus == -1) {
      engineStatusStr = "NOT_INITIALIZED";
      var status = await LoplatPlengiPlugin.start("loplat", "loplatsecret");
      if (status == 0) {
        engineStatusStr = "STARTED";
      }
    } else if (engineStatus == 0) {
      engineStatusStr = "STOPPED";
      if (Platform.isIOS) {
        var status = await LoplatPlengiPlugin.start("loplat", "loplatsecret");
        if (status == 0) {
          engineStatusStr = "STARTED";
        }
      }
    } else if (engineStatus == 1) {
      engineStatusStr = "STARTED";
    } else if (engineStatus == 2) {
      engineStatusStr = "STOPPED_TEMP";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _plengiStatus = engineStatusStr;
    });
  }

  updateLog(String log) {
    initPlatformState();
    print(log);
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
    String formattedDate = DateFormat('MM-dd HH:mm:ss').format(DateTime.now());
    setState(() {
      _loplatResults = '$formattedDate\n$locationInfo\n\n$_loplatResults';
      getLocationButEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'loplat SDK plugin example app',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Builder(
          builder: (context) => _buildBody(context)
        )
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                    'Running on: $_platformVersion\nplaceEngineStatus: $_plengiStatus'),
                ElevatedButton(
                  child: const Text('Get Location'),
                  onPressed: getLocationButEnabled? () {
                    setState(() {
                      getLocationButEnabled = false;
                    });
                    Timer _timer = Timer(const Duration(seconds: 8), () {
                      setState(() {
                        if (!getLocationButEnabled) {
                          getLocationButEnabled = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('응답시간이 초과되었습니다'))
                          );
                        }
                      });
                    });
                    _getCurrentPlace().then((value) {
                      _timer.cancel();
                      updateLog(value!);
                    });
                  }: null,
                ),
                Expanded(
                    flex: 1,
                    child: Align (alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                            child: Text(_loplatResults)
                        )
                    )
                )
              ],
            ),
          ),
        ));
  }

  Future<String?> _getCurrentPlace() async {
    String? res = await LoplatPlengiPlugin.testRefreshPlaceForeground();
    return res;
  }
}
