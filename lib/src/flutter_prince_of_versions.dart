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

  Future<void> checkForUpdatesFromGooglePlay(String url) async {
    if (Platform.isIOS) {
      return;
    }
    await _channel.invokeMethod(Constants.checkUpdatesFromPlayStoreMethodName, [url]);
  }

  Future<dynamic> _handleAndroidInvocations(MethodCall call) async {
    List<dynamic> arguments = call.arguments as List<dynamic>;
    if (call.method == Constants.canceled) {
      // Canceled
      _callback.canceled();
    } else if (call.method == Constants.mandatoryUpdateNotAvailable) {
      // Mandatory update not available
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments.last;
      _callback.mandatoryUpdateNotAvailable(QueenOfVersionsUpdateData.fromMap(firstArg), UpdateInfo.fromMap(secondArg));
    } else if (call.method == Constants.downloaded) {
      // Downloaded
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.downloaded(QueenOfVersionsUpdateData.fromMap(firstArg));
    } else if (call.method == Constants.downloading) {
      // Downloading
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.downloading(QueenOfVersionsUpdateData.fromMap(firstArg));
    } else if (call.method == Constants.error) {
      // Error
      _callback.error();
    } else if (call.method == Constants.installed) {
      // Installed
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.installed(QueenOfVersionsUpdateData.fromMap(firstArg));
    } else if (call.method == Constants.installing) {
      // Installing
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.installing(QueenOfVersionsUpdateData.fromMap(firstArg));
    } else if (call.method == Constants.updateAccepted) {
      // Updat accepted
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments[1];
      final Map<dynamic, dynamic> thirdArg = arguments.last;
      _callback.updateAccepted(
          QueenOfVersionsUpdateData.fromMap(firstArg), Status.fromMap(secondArg), UpdateData.fromMap(thirdArg));
    } else if (call.method == Constants.updateDeclined) {
      // Update declined
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments[1];
      final Map<dynamic, dynamic> thirdArg = arguments.last;
      _callback.updateDeclined(
          QueenOfVersionsUpdateData.fromMap(firstArg), Status.fromMap(secondArg), UpdateData.fromMap(thirdArg));
    } else if (call.method == Constants.noUpdateCallback) {
      // No update
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.noUpdate(UpdateInfo.fromMap(firstArg));
    } else if (call.method == Constants.onPending) {
      // On pending
      final Map<dynamic, dynamic> firstArg = arguments.first;
      _callback.onPending(QueenOfVersionsUpdateData.fromMap(firstArg));
    } else if (call.method == Constants.requestOptions) {
      // Request options - iOS only
      return _callback.requestOptions(arguments.first as String, arguments.last as String);
    }
  }
}
