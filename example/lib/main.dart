import 'package:flutter/material.dart';
import 'dart:async';

import 'package:hypertrack_plugin/hypertrack.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const key = 'paste_your_key_here';
  String _result = 'Not initialized';
  String _deviceId = '';
  HyperTrack sdk;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initializeSdk() async {
    HyperTrack.enableDebugLogging();
    // Initializer is just a helper class to get the actual sdk instance
    String result = 'failure';
    try {
      sdk = await HyperTrack.initialize(key);
      result = 'initialized';
      sdk.setDeviceName("Flutter Elvis");
      sdk.setDeviceMetadata({"source": "flutter sdk"});
      sdk.onTrackingStateChanged.listen((TrackingStateChange event) {
        if (mounted) {
          setState(() {
            _result = '$event';
          });
        }
      });
    } catch (e) {
      print(e);
    }

    final deviceId = (sdk == null) ? "unknown" : await sdk.getDeviceId();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _result = result;
      _deviceId = deviceId;
    });
  }

  void start() => sdk.start();

  void stop() => sdk.stop();

  void syncDeviceSettings() => sdk.syncDeviceSettings();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Initialization result is $_result',
              ),
              Text(
                'Device id is $_deviceId',
              ),
              ButtonBar(
                children: [
                  FlatButton(onPressed: start, child: Text("Start")),
                  FlatButton(
                      onPressed: initializeSdk, child: Text("Initialize")),
                  FlatButton(onPressed: stop, child: Text("Stop")),
                  FlatButton(
                      onPressed: syncDeviceSettings, child: Text("Sync")),
                ],
                alignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
