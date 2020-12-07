import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prince_of_versions/flutter_prince_of_versions.dart';

class MyCallback extends Callback {
  MyCallback(BuildContext context) {
    _context = context;
  }
  BuildContext _context;
  @override
  void canceled() {
    // no-op
  }

  @override
  void downloaded() {
    // no-op
  }

  @override
  void downloading() {
    // no-op
  }

  @override
  void error() {
    showDialog<bool>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('An error occurred'),
          content: Text('Cannot check your app status on Play Store'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              isDestructiveAction: false,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  @override
  void installed() {
    // no-op
  }

  @override
  void installing() {
    // no-op
  }

  @override
  void mandatoryUpdateNotAvailable() {
    // no-op
  }

  @override
  void noUpdate() {
    // no-op
  }

  @override
  void onPending() {
    // no-op
  }

  @override
  void updateAccepted() {
    // no-op
  }

  @override
  void updateDeclined() {
    // no-op
  }
}
