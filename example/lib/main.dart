import 'package:flutter/material.dart';
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
  late TextEditingController _publishableKey;
  late TextEditingController _deviceName;

  @override
  void initState() {
    super.initState();
    _publishableKey = TextEditingController(
        text: '!!-Place your public key here-!!');
    _deviceName = TextEditingController(text: "Lightning");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HyperTrack Quickstart'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  labelText: "Device Name",
                  suffixIcon: TextButton(
                    onPressed: () => _hypertrackFlutterPlugin
                        ?.setDeviceName(_deviceName.text),
                    child: const Text("Update"),
                  ),
                ),
                controller: _deviceName,
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => initHyperTrack(),
                  child: const Text("Initialize SDK"),
                ),
                TextButton(
                  onPressed: () => _hypertrackFlutterPlugin.start(),
                  child: const Text("Start Tracking"),
                ),
                TextButton(
                  onPressed: () => _hypertrackFlutterPlugin.stop(),
                  child: const Text("Stop Tracking"),
                ),
                TextButton(
                  onPressed: () async =>
                      _hypertrackFlutterPlugin.syncDeviceSettings(),
                  child: const Text("Sync Device Settings"),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: ListTile(
            title: Text(
              "Tracking Status:",
              style: const TextStyle(color: Colors.white),
            ),
           ),
        ),
      ),
    );
  }

  void initHyperTrack() async {
    _hypertrackFlutterPlugin =
        await HyperTrack().initialize(_publishableKey.text);
  }
}
