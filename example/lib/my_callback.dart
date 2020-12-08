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
  void downloaded(QueenOfVersionsUpdateData queenData) {
    // no-op
  }

  @override
  void downloading(QueenOfVersionsUpdateData queenData) {
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
  void installed(QueenOfVersionsUpdateData queenData) {
    // no-op
  }

  @override
  void installing(QueenOfVersionsUpdateData queenData) {
    // no-op
  }

  @override
  void mandatoryUpdateNotAvailable(QueenOfVersionsUpdateData queenData, UpdateInfo updateInfo) {
    // no-op
  }

  @override
  void noUpdate(UpdateInfo updateInfo) {
    // no-op
  }

  @override
  void onPending(QueenOfVersionsUpdateData queenData) {
    // no-op
  }

  @override
  void updateAccepted(QueenOfVersionsUpdateData queenData, UpdateStatus status, UpdateData updateData) {
    // no-op
  }

  @override
  void updateDeclined(QueenOfVersionsUpdateData queenData, UpdateStatus status, UpdateData updateData) {
    // no-op
  }

  @override
  bool requestOptions(String key, String value) {
    if (key == "region") {
      return value == "hr";
    }
    return true;
  }
}
