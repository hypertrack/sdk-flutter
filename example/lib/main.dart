import 'package:flutter/material.dart';
import 'package:hypertrack_plugin/const/constants.dart';
import 'package:hypertrack_plugin/hypertrack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HyperTrack _hypertrackFlutterPlugin = HyperTrack();
  final String _publishableKey = "<-- Place public key here -->";
  final String _deviceName = 'Lightning';
  String _result = 'Not initialized';
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    initHyperTrack();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: Colors.green),
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('HyperTrack Quickstart'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              SizedBox(height: 10),
              ListTile(
                leading: const Text("Device name"),
                trailing: Text(
                  _deviceName,
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: isRunning ? Colors.red : Colors.green),
                    onPressed: () {
                      isRunning
                          ? _hypertrackFlutterPlugin.stop()
                          : _hypertrackFlutterPlugin.start();
                      setState(() {});
                    },
                    child:
                    Text(isRunning ? "Stop Tracking" : "Start Tracking"),


                  ),
                  ElevatedButton(
                    onPressed: () async =>
                        _hypertrackFlutterPlugin.syncDeviceSettings(),
                    child: const Text("Sync Settings"),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: ListTile(
            leading: Text("Status"),
            trailing: Text(_result),
          )),
    );
  }

  void initHyperTrack() async {
    _hypertrackFlutterPlugin = await HyperTrack().initialize(_publishableKey);
    _hypertrackFlutterPlugin.setDeviceName(_deviceName);
    _hypertrackFlutterPlugin.setDeviceMetadata({"source": "flutter sdk"});
    _hypertrackFlutterPlugin.onTrackingStateChanged
        .listen((TrackingStateChange event) {
      if (mounted) {
        updateButtonState();
        _result = getTrackingStatus(event);
        setState(() {});
      }
    });
  }

  void updateButtonState() async {
    final temp = await _hypertrackFlutterPlugin.isRunning();
    isRunning = temp;
    setState(() {});
  }
}

String getTrackingStatus (TrackingStateChange event) {
  Map<TrackingStateChange, String> statusMap = {
    TrackingStateChange.start: "Tracking Started",
    TrackingStateChange.stop: "Tracking Stop",
    TrackingStateChange.unknownError: "Unknown Error",
    TrackingStateChange.authError: "Authentication Error",
    TrackingStateChange.networkError: "Network Error",
    TrackingStateChange.invalidToken: "Invalid Token",
    TrackingStateChange.locationDisabled: "Location Disabled",
    TrackingStateChange.permissionsDenied: "Permissions Denied",
  };
  if (statusMap[event] == null) {
    throw Exception("Unexpected null value in getTrackingStatus");
  }
  return statusMap[event]!;
}