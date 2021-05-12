import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prince_of_versions/flutter_prince_of_versions.dart';

import 'my_callback.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: MyApp())));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String androidUrl = 'https://pastebin.com/raw/FBMxHpN7';
  String iOSUrl = 'https://pastebin.com/raw/0MfYmWGu';

  Future<void> _checkForUpdates() async {
    String url = Platform.isAndroid ? androidUrl : iOSUrl;

    try {
      final updateData = await FlutterPrinceOfVersions.checkForUpdates(
        url: url,
        requirementChecks: {
          'region': (value) {
            return value == 'hr';
          },
          'bluetooth': (value) {
            return value == '5.0';
          }
        },
      );

      print('Update status: ${updateData.status}');
      print('Installed version: ${updateData.updateInfo.installedVersion}');
      print(
          'Last available major version: ${updateData.updateInfo.lastVersionAvailable?.major}');
      print('Metadata: ${updateData.metadata}');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _checkForUpdatesFromAppStore() async {
    final updateData =
        await FlutterPrinceOfVersions.checkForUpdatesFromAppStore();
    print('Update status: ${updateData.status}');
    print('Current version: ${updateData.version.major}');
  }

  Future<void> _checkForUpdatesFromGooglePlay() async {
    final Callback callback = MyCallback(context);
    await FlutterPrinceOfVersions.checkForUpdatesFromGooglePlay(
        "http://pastebin.com/raw/QFGjJrLP", callback);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(height: 100),
          Center(
            child: Text(
              'Prince of Versions example',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 40),
          CupertinoButton.filled(
            child: Text('Check for updates'),
            onPressed: _checkForUpdates,
          ),
          SizedBox(height: 20),
          CupertinoButton.filled(
            child: Text('App Store test'),
            onPressed: _checkForUpdatesFromAppStore,
          ),
          SizedBox(height: 20),
          CupertinoButton.filled(
            child: Text('Google Play test'),
            onPressed: _checkForUpdatesFromGooglePlay,
          ),
        ],
      ),
    );
  }
}
