part of flutter_prince_of_versions;

/// Library for checking if an update is available for your application.
/// [FlutterPrinceOfVersions] parses a JSON response stored on server and returns the result.
/// There are three possible results: [UpdateStatus.noUpdateAvailable], [UpdateStatus.requiredUpdateNeeded] and
/// [UpdateStatus.newUpdateAvailable]. No update means there is not any available update for your application.
/// Required update means that and update is available and that the user must download and install it before using the app.
/// If the result is New update then user should be notified that he can install a new version of the application.
/// Additionally, you can create a custom flow using [checkForUpdates] method which will return parsed JSON data.
class FlutterPrinceOfVersions {
  FlutterPrinceOfVersions._();
  static const MethodChannel _channel = const MethodChannel(Constants.channelName);

  /// Returns true if [UpdateStatus] is [UpdateStatus.newUpdateAvailable] or [UpdateStatus.requiredUpdateNeeded].
  /// Receives an url to the JSON.
  static Future<bool> isUpdateAvailable(String url) async {
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(Constants.checkForUpdatesMethodName, [url]);
    final UpdateData updateData = UpdateData.fromMap(data);
    return updateData.status == UpdateStatus.newUpdateAvailable ||
        updateData.status == UpdateStatus.requiredUpdateNeeded;
  }

  /// Returns parsed JSON data modeled as [UpdateData].
  /// Receives an url to the JSON.
  static Future<UpdateData> checkForUpdates(String url) async {
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(Constants.checkForUpdatesMethodName, [url]);
    return UpdateData.fromMap(data);
  }

  /// Returns true only if [UpdateStatus] is [UpdateStatus.requiredUpdateNeeded].
  /// Receives an url to the JSON.
  static Future<bool> isMandatoryUpdateAvailable(String url) async {
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(Constants.checkForUpdatesMethodName, [url]);
    final UpdateData updateData = UpdateData.fromMap(data);
    return updateData.status == UpdateStatus.requiredUpdateNeeded;
  }

  /// Returns information from PlayStore or AppStore as [UpdateData].
  /// NOTE: Not tested yet.
  static Future<UpdateData> checkForUpdatesFromStore() async {
    final Map<dynamic, dynamic> data = await _channel.invokeMethod(Constants.checkUpdatesFromStoreMethodName);
    return UpdateData.fromMap(data);
  }
}
