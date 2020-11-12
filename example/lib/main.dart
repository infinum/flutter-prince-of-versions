import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: MyApp())));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String key = 'pwdkey';
  String secret = '1111';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(height: 100),
          Center(
            child: Text(
              'Locker example',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 40),
          CupertinoButton.filled(child: Text('Can authenticate'), onPressed: () {}),
          SizedBox(height: 20),
          CupertinoButton.filled(child: Text('Save secret'), onPressed: () {}),
          SizedBox(height: 20),
          CupertinoButton.filled(child: Text('Retrieve secret'), onPressed: () {}),
          SizedBox(height: 20),
          CupertinoButton.filled(child: Text('Delete secret'), onPressed: () {})
        ],
      ),
    );
  }
}
