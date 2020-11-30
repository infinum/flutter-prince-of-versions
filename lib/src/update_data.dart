part of flutter_prince_of_versions;

/// Update status of the application.
enum UpdateStatus {
  noUpdateAvailable,
  requiredUpdateNeeded,
  newUpdateAvailable,
}

extension Status on UpdateStatus {
  static UpdateStatus _fromMap(dynamic status) {
    final String currentStatus = status as String;
    switch (currentStatus) {
      case Constants.updateAvailable:
        return UpdateStatus.newUpdateAvailable;
      case Constants.noUpdate:
        return UpdateStatus.noUpdateAvailable;
      case Constants.requiredUpdate:
        return UpdateStatus.requiredUpdateNeeded;
    }
    return UpdateStatus.noUpdateAvailable;
  }
}

/// Information about the app.
class UpdateInfo {
  /// Last version that can be installed.
  Version lastVersionAvailable;

  /// Current installed version.
  Version installedVersion;

  /// Minimum required version.
  Version requiredVersion;

  static UpdateInfo _fromMap(Map<dynamic, dynamic> map) {
    final UpdateInfo updateInfo = UpdateInfo();
    updateInfo.lastVersionAvailable =
        map[Constants.lastVersionAvailable] != null ? Version._fromMap(map[Constants.lastVersionAvailable]) : null;
    updateInfo.installedVersion =
        map[Constants.installedVersion] != null ? Version._fromMap(map[Constants.installedVersion]) : null;
    updateInfo.requiredVersion =
        map[Constants.requiredVersion] != null ? Version._fromMap(map[Constants.requiredVersion]) : null;
    return updateInfo;
  }
}

/// Version of the app. On Android only major is used.
class Version {
  /// App major version number. iOS and Android.
  int major;

  /// App minor version number. iOS only.
  int minor;

  /// App patch version number. iOS only.
  int patch;

  /// App build version number. iOS only.
  int build;

  static Version _fromMap(Map<dynamic, dynamic> map) {
    final Version version = Version();
    version.major = map[Constants.major];
    version.minor = map[Constants.minor];
    version.patch = map[Constants.patch];
    version.build = map[Constants.build];
    return version;
  }
}

/// Whole data about the application form JSON.
/// Can be used in custom flows. For example:
/// If UpdateInfo.lastAvailableVersion.major > 2 don't do anything.
class UpdateData {
  UpdateStatus status;
  Version version;
  UpdateInfo updateInfo;

  static UpdateData fromMap(Map<dynamic, dynamic> map) {
    final UpdateData data = UpdateData();
    data.status = map[Constants.status] != null ? Status._fromMap(map[Constants.status]) : null;
    data.version = map[Constants.version] != null ? Version._fromMap(map[Constants.version]) : null;
    data.updateInfo = map[Constants.updateInfo] != null ? UpdateInfo._fromMap(map[Constants.updateInfo]) : null;
    return data;
  }
}