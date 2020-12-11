part of flutter_prince_of_versions;

/// Library for checking if an update is available for your application.
/// [FlutterPrinceOfVersions] parses a JSON response stored on server and returns the result.
/// There are three possible results: [UpdateStatus.noUpdateAvailable], [UpdateStatus.requiredUpdateNeeded] and
/// [UpdateStatus.newUpdateAvailable]. [UpdateStatus.noUpdateAvailable] means there is not any available update for your application.
/// [UpdateStatus.requiredUpdateNeeded] means that and update is available and that the user must download and install it before using the app.
/// If the result is [UpdateStatus.newUpdateAvailable] then user should be notified that he can install a new version of the application.
class FlutterPrinceOfVersions {
  FlutterPrinceOfVersions._();

  static MethodChannel _channel = const MethodChannel(Constants.channelName);
  static MethodChannel _requirementsChannel = const MethodChannel(Constants.requirementsChannelName);

  /// Returns parsed JSON data modeled as [UpdateData].
  /// [url] to the JSON.
  /// [shouldPinCertificates] - iOS only. Indicates whether PoV should use security keys from all certificates found in the main bundle. Default is false.
  /// [httpHeaderFields] - iOS only. Http header fields.
  /// [requestOptions] - Adds requirement check for configuration. Map key that matches key in requirements array in JSON with requirementsCheck parameter.
  /// Map value for key is a method that will be called when checking if the value of requirement is valid. This method is expected to return a bool.
  /// If the method does not return a bool, whole requirement will be false.
  static Future<UpdateData> checkForUpdates(
      {@required String url,
      bool shouldPinCertificates,
      Map<String, String> httpHeaderFields,
      Map<String, Function> requestOptions}) async {
    if (requestOptions != null) {
      _requirementsChannel.setMethodCallHandler((call) => _handleRequirementInvocations(call, requestOptions));
    }
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(Constants.checkForUpdatesMethodName,
        [url, shouldPinCertificates, httpHeaderFields, requestOptions.keys.toList()]);
    return UpdateData.fromMap(data);
  }

  /// Returns information from AppStore as [UpdateData].
  /// Uses your applications Bundle ID to fetch data from App Store.
  /// [notifyOnce] - determines if the app should be notified only once of the update status or always. Default setting is false.
  /// [trackPhasedRelease] - bool that indicates whether PoV should notify about new version after 7 days when app is fully rolled out or immediately. Default value is true.
  static Future<UpdateData> checkForUpdatesFromAppStore(
      {bool trackPhasedRelease = true, bool notifyOnce = false}) async {
    if (Platform.isAndroid) {
      return null;
    }
    final Map<dynamic, dynamic> data =
        await _channel.invokeMethod(Constants.checkUpdatesFromAppStoreMethodName, [trackPhasedRelease, notifyOnce]);
    return UpdateData.fromMap(data);
  }

  /// Checks Google Store data for your application. If your application is not on Google Store, error method in callback is triggered.
  /// Brings native Android update alert. Depending on different update states, different callback methods are triggered.
  /// [callback] - your implementation of possible update states
  static Future<void> checkForUpdatesFromGooglePlay(Callback callback) async {
    if (Platform.isIOS) {
      return;
    }
    _channel.setMethodCallHandler((call) => _handleAndroidInvocations(call, callback));
    await _channel.invokeMethod(Constants.checkUpdatesFromPlayStoreMethodName);
  }

  static Future<void> _handleAndroidInvocations(MethodCall call, Callback callback) async {
    if (call.method == Constants.canceled) {
      callback.canceled();
    } else if (call.method == Constants.mandatoryUpdateNotAvailable) {
      List<dynamic> arguments = call.arguments as List<dynamic>;
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments.last;
      callback.mandatoryUpdateNotAvailable(QueenOfVersionsUpdateData.fromMap(firstArg), UpdateInfo.fromMap(secondArg));
    } else if (call.method == Constants.downloaded) {
      callback.downloaded(QueenOfVersionsUpdateData.fromMap(call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.downloading) {
      callback.downloading(QueenOfVersionsUpdateData.fromMap(call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.error) {
      callback.error(call.arguments as String);
    } else if (call.method == Constants.installed) {
      callback.installed(QueenOfVersionsUpdateData.fromMap(call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.installing) {
      callback.installing(QueenOfVersionsUpdateData.fromMap(call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.updateAccepted) {
      List<dynamic> arguments = call.arguments as List<dynamic>;
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments[1];
      final Map<dynamic, dynamic> thirdArg = arguments.last;
      callback.updateAccepted(
          QueenOfVersionsUpdateData.fromMap(firstArg), Status.fromMap(secondArg), UpdateData.fromMap(thirdArg));
    } else if (call.method == Constants.updateDeclined) {
      List<dynamic> arguments = call.arguments as List<dynamic>;
      final Map<dynamic, dynamic> firstArg = arguments.first;
      final Map<dynamic, dynamic> secondArg = arguments[1];
      final Map<dynamic, dynamic> thirdArg = arguments.last;
      callback.updateDeclined(
          QueenOfVersionsUpdateData.fromMap(firstArg), Status.fromMap(secondArg), UpdateData.fromMap(thirdArg));
    } else if (call.method == Constants.noUpdateCallback) {
      callback.noUpdate(UpdateInfo.fromMap(call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.onPending) {
      callback.onPending(QueenOfVersionsUpdateData.fromMap(call.arguments as Map<dynamic, dynamic>));
    }
  }

  static Future<bool> _handleRequirementInvocations(MethodCall call, Map<String, Function> options) async {
    final List<dynamic> arguments = call.arguments as List<dynamic>;
    return options[arguments.first as String](arguments.last as String);
  }
}
