import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prince_of_versions/flutter_prince_of_versions.dart';

class MyCallback extends Callback {
  MyCallback(this._context);

  final BuildContext _context;

  @override
  void error(String localizedMessage) {
    showDialog<bool>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('An error occurred'),
          content: Text('$localizedMessage'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }
}
