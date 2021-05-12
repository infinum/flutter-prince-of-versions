part of flutter_prince_of_versions;

/// Signature for a function that checks if a requirement is satisfied.
typedef RequirementCheck = FutureOr<bool> Function(dynamic);

/// Library for checking if an update is available for your application.
/// [FlutterPrinceOfVersions] parses a JSON response stored on server and returns the result.
/// There are three possible results: [UpdateStatus.noUpdateAvailable], [UpdateStatus.requiredUpdateNeeded] and
/// [UpdateStatus.newUpdateAvailable]. [UpdateStatus.noUpdateAvailable] means there is not any available update for your application.
/// [UpdateStatus.requiredUpdateNeeded] means that and update is available and that the user must download and install it before using the app.
/// If the result is [UpdateStatus.newUpdateAvailable] then user should be notified that he can install a new version of the application.
class FlutterPrinceOfVersions {
  FlutterPrinceOfVersions._();

  static const _channel = MethodChannel(Constants.channelName);
  static const _requirementsChannel =
      MethodChannel(Constants.requirementsChannelName);

  /// Returns parsed JSON data modeled as [UpdateData].
  /// [url] to the JSON.
  /// [shouldPinCertificates] - iOS only. Indicates whether PoV should use security keys from all certificates found in the main bundle. Default is false.
  /// [httpHeaderFields] - iOS only. Http header fields.
  /// [requirementChecks] - Map of requirement keys and associated checks. A check determines if the value of the given requirement key satisfies the requirement.
  /// If JSON data model provides a requirement for which a [RequirementCheck] is not supplied, the requirement will be consider as not satisfied.
  /// If the method does not return a bool, whole requirement will be false.
  /// This method will throw an error if it does not manage to fetch JSON data.
  static Future<UpdateData> checkForUpdates({
    required String url,
    bool shouldPinCertificates = false,
    Map<String, String> httpHeaderFields = const {},
    Map<String, RequirementCheck> requirementChecks = const {},
  }) async {
    _requirementsChannel.setMethodCallHandler((call) =>
        _handleRequirementsChannelMethodCall(call, requirementChecks));
    final data =
        await _channel.invokeMethod(Constants.checkForUpdatesMethodName, [
      url,
      shouldPinCertificates,
      httpHeaderFields,
      requirementChecks.keys.toList(),
    ]) as Map<dynamic, dynamic>;
    return UpdateData.fromMap(data);
  }

  /// Returns information from AppStore as [UpdateData].
  /// Uses your applications Bundle ID to fetch data from App Store.
  /// [trackPhasedRelease] - bool that indicates whether PoV should notify about new version after 7 days when app is fully rolled out or immediately. Default is true.
  /// [notifyOnce] - determines if the app should be notified only once of the update status or always. Default is false.
  /// This method will throw if it is invoked from a platform other than iOS.
  /// This method will throw if it does not manage to check for updates.
  static Future<UpdateData> checkForUpdatesFromAppStore({
    bool trackPhasedRelease = true,
    bool notifyOnce = false,
  }) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('This method is only supported on iOS.');
    }
    final data = await _channel
        .invokeMethod(Constants.checkForUpdatesFromAppStoreMethodName, [
      trackPhasedRelease,
      notifyOnce,
    ]) as Map<dynamic, dynamic>;
    return UpdateData.fromMap(data);
  }

  /// Checks Google Play data for this application. If your application is not on Google Play, [Callback.error] is called.
  /// Brings native Android update alert. Depending on different update states, different callback methods are triggered.
  /// [url] - url to your application on the Google Play.
  /// [callback] - your implementation of possible update states.
  static Future<void> checkForUpdatesFromGooglePlay(
      String url, Callback callback) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This method is only supported on Android.');
    }
    _channel.setMethodCallHandler(
        (call) => _handleAndroidInvocations(call, callback));

    await _channel.invokeMethod(
      Constants.checkForUpdatesFromGooglePlayMethodName,
      [url],
    );
  }

  static Future<void> _handleAndroidInvocations(
      MethodCall call, Callback callback) async {
    if (call.method == Constants.canceled) {
      callback.canceled();
    } else if (call.method == Constants.mandatoryUpdateNotAvailable) {
      final arguments = call.arguments as List<dynamic>;
      final arg0 = arguments[0] as Map<dynamic, dynamic>;
      final arg1 = arguments[1] as Map<dynamic, dynamic>;
      callback.mandatoryUpdateNotAvailable(
          QueenOfVersionsUpdateData.fromMap(arg0), UpdateInfo.fromMap(arg1));
    } else if (call.method == Constants.downloaded) {
      callback.downloaded(QueenOfVersionsUpdateData.fromMap(
          call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.downloading) {
      callback.downloading(QueenOfVersionsUpdateData.fromMap(
          call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.error) {
      callback.error(call.arguments as String);
    } else if (call.method == Constants.installed) {
      callback.installed(QueenOfVersionsUpdateData.fromMap(
          call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.installing) {
      callback.installing(QueenOfVersionsUpdateData.fromMap(
          call.arguments as Map<dynamic, dynamic>));
    } else if (call.method == Constants.updateAccepted) {
      final arguments = call.arguments as List<dynamic>;
      final arg0 = arguments[0] as Map<dynamic, dynamic>;
      final arg1 = arguments[1] as String;
      final arg2 = arguments[2] as Map<dynamic, dynamic>?;
      callback.updateAccepted(
        QueenOfVersionsUpdateData.fromMap(arg0),
        UpdateStatusMapper.map(arg1),
        arg2 != null ? UpdateData.fromMap(arg2) : null,
      );
    } else if (call.method == Constants.updateDeclined) {
      final arguments = call.arguments as List<dynamic>;
      final arg0 = arguments[0] as Map<dynamic, dynamic>;
      final arg1 = arguments[1] as String;
      final arg2 = arguments[2] as Map<dynamic, dynamic>?;
      callback.updateDeclined(
        QueenOfVersionsUpdateData.fromMap(arg0),
        UpdateStatusMapper.map(arg1),
        arg2 != null ? UpdateData.fromMap(arg2) : null,
      );
    } else if (call.method == Constants.noUpdateCallback) {
      final arg = call.arguments as Map<dynamic, dynamic>?;
      callback.noUpdate(
        arg != null ? UpdateInfo.fromMap(arg) : null,
      );
    } else if (call.method == Constants.onPending) {
      callback.onPending(QueenOfVersionsUpdateData.fromMap(
          call.arguments as Map<dynamic, dynamic>));
    }
  }

  static Future<bool> _handleRequirementsChannelMethodCall(
      MethodCall call, Map<String, RequirementCheck> requirementChecks) async {
    switch (call.method) {
      case Constants.checkRequirementMethodName:
        {
          final arguments = call.arguments as List<dynamic>;
          final requirementKey = arguments[0] as String;
          final requirementValue = arguments[1];

          final requirementCheck = requirementChecks[requirementKey];
          return (await requirementCheck?.call(requirementValue)) ?? false;
        }
    }
    throw Error();
  }
}
