part of '../flutter_prince_of_versions.dart';

/// Signature for a function that checks if a requirement is satisfied.
typedef RequirementCheck = FutureOr<bool> Function(dynamic);

/// Library for checking if an application update is available.
class FlutterPrinceOfVersions {
  FlutterPrinceOfVersions._();

  static const _channel = MethodChannel(Constants.channelName);
  static const _requirementsChannel =
      MethodChannel(Constants.requirementsChannelName);

  /// Checks for application updates, by parsing the version configuration fetched from an url.
  ///
  /// Returns [UpdateData] parsed from JSON version configuration.
  /// [url] - Url to the version configuration.
  /// [shouldPinCertificates] - iOS only. Indicates whether it should use security keys from all certificates found in the main bundle. Defaults to false.
  /// [httpHeaderFields] - iOS only. Http header fields.
  /// [requirementChecks] - Map of requirement keys and associated checks. A check determines if the value of the given requirement key satisfies the requirement.
  /// If the version configuration provides a requirement for which a [RequirementCheck] is not supplied, the requirement will be consider as not satisfied.
  /// Throws if it does not manage to fetch the version configuration.
  static Future<UpdateData> checkForUpdates({
    required String url,
    bool shouldPinCertificates = false,
    Map<String, String> httpHeaderFields = const {},
    Map<String, RequirementCheck> requirementChecks = const {},
  }) async {
    _requirementsChannel.setMethodCallHandler((call) =>
        _handleRequirementsChannelMethodCall(call, requirementChecks));

    final data = await _channel.invokeMethod(
      Constants.checkForUpdatesMethodName,
      [
        url,
        shouldPinCertificates,
        httpHeaderFields,
        requirementChecks.keys.toList(),
      ],
    ) as Map<dynamic, dynamic>;

    return UpdateData._fromMap(data);
  }

  /// Checks App Store for application updates.
  ///
  /// Uses application Bundle ID, to check for updates.
  /// [trackPhasedRelease] - Indicates whether it should notify about a new version after 7 days when app is fully rolled out or immediately. Defaults to true.
  /// [notifyOnce] - Determines if the app should be notified for a new update only once. Defaults to false.
  /// Throws if invoked from a platform other than iOS.
  /// Throws if it does not manage to check for updates.
  static Future<UpdateData> checkForUpdatesFromAppStore({
    bool trackPhasedRelease = true,
    bool notifyOnce = false,
  }) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('This method is only supported on iOS.');
    }

    final data = await _channel.invokeMethod(
      Constants.checkForUpdatesFromAppStoreMethodName,
      [
        trackPhasedRelease,
        notifyOnce,
      ],
    ) as Map<dynamic, dynamic>;

    return UpdateData._fromMap(data);
  }

  /// Checks Google Play for application updates.
  ///
  /// Shows native Android update alert.
  /// [url] - Url of the application on the Google Play.
  /// [callback] - Callbacks for reacting to update states.
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
      final args = call.arguments as List<dynamic>;
      final arg0 = args[0] as Map<dynamic, dynamic>;
      final arg1 = args[1] as Map<dynamic, dynamic>;

      callback.mandatoryUpdateNotAvailable(
        QueenOfVersionsUpdateData._fromMap(arg0),
        UpdateInfo._fromMap(arg1),
      );
    } else if (call.method == Constants.downloaded) {
      final arg = call.arguments as Map<dynamic, dynamic>;

      callback.downloaded(
        QueenOfVersionsUpdateData._fromMap(arg),
      );
    } else if (call.method == Constants.downloading) {
      final arg = call.arguments as Map<dynamic, dynamic>;

      callback.downloading(
        QueenOfVersionsUpdateData._fromMap(arg),
      );
    } else if (call.method == Constants.error) {
      final arg = call.arguments as String;

      callback.error(arg);
    } else if (call.method == Constants.installed) {
      final arg = call.arguments as Map<dynamic, dynamic>;

      callback.installed(
        QueenOfVersionsUpdateData._fromMap(arg),
      );
    } else if (call.method == Constants.installing) {
      final arg = call.arguments as Map<dynamic, dynamic>;

      callback.installing(
        QueenOfVersionsUpdateData._fromMap(arg),
      );
    } else if (call.method == Constants.updateAccepted) {
      final args = call.arguments as List<dynamic>;
      final arg0 = args[0] as Map<dynamic, dynamic>;
      final arg1 = args[1] as String;
      final arg2 = args[2] as Map<dynamic, dynamic>?;

      callback.updateAccepted(
        QueenOfVersionsUpdateData._fromMap(arg0),
        _UpdateStatusMapper.map(arg1),
        arg2 != null ? UpdateData._fromMap(arg2) : null,
      );
    } else if (call.method == Constants.updateDeclined) {
      final args = call.arguments as List<dynamic>;
      final arg0 = args[0] as Map<dynamic, dynamic>;
      final arg1 = args[1] as String;
      final arg2 = args[2] as Map<dynamic, dynamic>?;

      callback.updateDeclined(
        QueenOfVersionsUpdateData._fromMap(arg0),
        _UpdateStatusMapper.map(arg1),
        arg2 != null ? UpdateData._fromMap(arg2) : null,
      );
    } else if (call.method == Constants.noUpdateCallback) {
      final arg = call.arguments as Map<dynamic, dynamic>?;

      callback.noUpdate(
        arg != null ? UpdateInfo._fromMap(arg) : null,
      );
    } else if (call.method == Constants.onPending) {
      final arg = call.arguments as Map<dynamic, dynamic>;

      callback.onPending(
        QueenOfVersionsUpdateData._fromMap(arg),
      );
    }
  }

  static Future<bool> _handleRequirementsChannelMethodCall(
      MethodCall call, Map<String, RequirementCheck> requirementChecks) async {
    if (call.method != Constants.checkRequirementMethodName) {
      throw Error();
    }

    final args = call.arguments as List<dynamic>;
    final requirementKey = args[0] as String;
    final requirementValue = args[1];

    final requirementCheck = requirementChecks[requirementKey];
    if (requirementCheck == null) {
      return false;
    }

    return requirementCheck.call(requirementValue);
  }
}
