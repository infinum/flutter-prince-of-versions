part of flutter_prince_of_versions;

/// Library for checking if an update is available for your application.
/// [FlutterPrinceOfVersions] parses a JSON response stored on server and returns the result.
/// There are three possible results: [UpdateStatus.noUpdateAvailable], [UpdateStatus.requiredUpdateNeeded] and
/// [UpdateStatus.newUpdateAvailable]. No update means there is not any available update for your application.
/// Required update means that and update is available and that the user must download and install it before using the app.
/// If the result is New update then user should be notified that he can install a new version of the application.
/// Additionally, you can create a custom flow using [checkForUpdates] method which will return parsed JSON data.
class FlutterPrinceOfVersions {
  FlutterPrinceOfVersions(Callback callback) {
    _callback = callback;
    _channel.setMethodCallHandler(_handleAndroidInvocations);
  }

  MethodChannel _channel = const MethodChannel(Constants.channelName);
  Callback _callback;

  /// Returns parsed JSON data modeled as [UpdateData].
  /// Receives an url to the JSON.
  Future<UpdateData> checkForUpdates(
      {@required String url,
      bool shouldPinCertificates,
      Map<String, String> httpHeaderFields,
      Map<String, dynamic> requestOptions}) async {
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(
        Constants.checkForUpdatesMethodName, [url, shouldPinCertificates, httpHeaderFields, requestOptions]);
    return UpdateData.fromMap(data);
  }

  /// Returns information from PlayStore or AppStore as [UpdateData].
  /// NOTE: Not tested yet.
  Future<UpdateData> checkForUpdatesFromAppStore({bool trackPhasedRelease = true, bool notifyOnce = false}) async {
    if (Platform.isAndroid) {
      return null;
    }
    final Map<dynamic, dynamic> data =
        await _channel.invokeMethod(Constants.checkUpdatesFromAppStoreMethodName, [trackPhasedRelease, notifyOnce]);
    return UpdateData.fromMap(data);
  }

  Future<void> checkForUpdatesFromGooglePlay() async {
    if (Platform.isIOS) {
      return;
    }
    await _channel.invokeMethod(Constants.checkUpdatesFromPlayStoreMethodName);
  }

  Future<void> _handleAndroidInvocations(MethodCall call) async {
    if (call.method == "canceled") {
      _callback.canceled();
    } else if (call.method == "mandatory_update_not_available") {
      _callback.mandatoryUpdateNotAvailable();
    } else if (call.method == "downloaded") {
      _callback.downloaded();
    } else if (call.method == "downloading") {
      _callback.downloading();
    } else if (call.method == "error") {
      _callback.error();
    } else if (call.method == "installed") {
      _callback.installed();
    } else if (call.method == "installing") {
      _callback.installing();
    } else if (call.method == "update_accepted") {
      _callback.updateAccepted();
    } else if (call.method == "update_declined") {
      _callback.updateDeclined();
    } else if (call.method == "no_update") {
      _callback.noUpdate();
    } else if (call.method == "on_pending") {
      _callback.onPending();
    }
  }
}
