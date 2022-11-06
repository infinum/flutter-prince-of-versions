// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prince_of_versions/flutter_prince_of_versions.dart';

import 'my_callback.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const androidUrl = 'https://pastebin.com/raw/FBMxHpN7';
  static const iOSUrl = 'https://pastebin.com/raw/0MfYmWGu';

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
      print('Last version: ${updateData.updateInfo.lastVersionAvailable}');
      print('Metadata: ${updateData.metadata}');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _checkForUpdatesFromAppStore() async {
    final updateData =
        await FlutterPrinceOfVersions.checkForUpdatesFromAppStore();
    print('Update status: ${updateData.status}');
    print('Current version: ${updateData.version}');
  }

  Future<void> _checkForUpdatesFromGooglePlay() async {
    final callback = MyCallback(context);
    await FlutterPrinceOfVersions.checkForUpdatesFromGooglePlay(
        "Google Play url", callback);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 100),
          const Center(
            child: Text(
              'Prince of Versions example',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 40),
          CupertinoButton.filled(
            onPressed: _checkForUpdates,
            child: const Text('Check for updates'),
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            onPressed: _checkForUpdatesFromAppStore,
            child: const Text('Check App Store updates'),
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            onPressed: _checkForUpdatesFromGooglePlay,
            child: const Text('Check Google Play updates'),
          ),
        ],
      ),
    );
  }
}
