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
              onPressed: () async {
                String url = Platform.isAndroid ? androidUrl : iOSUrl;

                final data = await FlutterPrinceOfVersions.checkForUpdates(url: url, shouldPinCertificates: false);
                print('Update status: ${data.status.toString()}');
                print('Current version: ${data.version.major}');
                print('Last available major version: ${data.updateInfo.lastVersionAvailable.major}');
              }),
          SizedBox(height: 20),
          CupertinoButton.filled(
              child: Text('App Store test'),
              onPressed: () async {
                final data = await FlutterPrinceOfVersions.checkForUpdatesFromAppStore(
                    trackPhasedRelease: true, notifyOnce: false);
              }),
          SizedBox(height: 20),
          CupertinoButton.filled(
              child: Text('Play Store test'),
              onPressed: () async {
                final Callback c = MyCallback(context);
                await FlutterPrinceOfVersions.checkForUpdatesFromGooglePlay("http://pastebin.com/raw/QFGjJrLP", c);
              }),
        ],
      ),
    );
  }

  void showAlert(String title, String content) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Ok"),
              isDestructiveAction: false,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }
}
