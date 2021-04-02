part of flutter_prince_of_versions;

/// Update status of the application.
enum UpdateStatus {
  noUpdateAvailable,
  requiredUpdateNeeded,
  newUpdateAvailable,
}

class UpdateStatusMapper {
  UpdateStatusMapper._();

  static UpdateStatus map(dynamic value) {
    final rawUpdateStatus = value as String;
    switch (rawUpdateStatus) {
      case Constants.updateAvailable:
        return UpdateStatus.newUpdateAvailable;
      case Constants.noUpdate:
        return UpdateStatus.noUpdateAvailable;
      case Constants.requiredUpdate:
        return UpdateStatus.requiredUpdateNeeded;
    }
    throw Error();
  }
}

/// Information about the app.
@immutable
class UpdateInfo {
  const UpdateInfo({
    this.lastVersionAvailable,
    required this.installedVersion,
    this.requiredVersion,
  });

  /// Last version that can be installed.
  final Version? lastVersionAvailable;

  /// Current installed version.
  final Version installedVersion;

  /// Minimum required version.
  final Version? requiredVersion;

  factory UpdateInfo.fromMap(Map<dynamic, dynamic> map) {
    return UpdateInfo(
      lastVersionAvailable:
          map.containsKey(Constants.lastVersionAvailable) ? Version.fromMap(map[Constants.lastVersionAvailable]) : null,
      installedVersion: Version.fromMap(map[Constants.installedVersion]),
      requiredVersion:
          map.containsKey(Constants.requiredVersion) ? Version.fromMap(map[Constants.requiredVersion]) : null,
    );
  }
}

/// Version of the app. On Android only major is used.
@immutable
class Version {
  const Version({
    required this.major,
    this.minor,
    this.patch,
    this.build,
  });

  /// App major version number. iOS and Android.
  final int major;

  /// App minor version number. iOS only.
  final int? minor;

  /// App patch version number. iOS only.
  final int? patch;

  /// App build version number. iOS only.
  final int? build;

  factory Version.fromMap(Map<dynamic, dynamic> map) {
    return Version(
      major: map[Constants.major] as int,
      minor: map[Constants.minor] as int?,
      patch: map[Constants.patch] as int?,
      build: map[Constants.build] as int?,
    );
  }

  String toString() {
    return '$major.$minor.$patch';
  }
}

/// Whole data about the application form JSON.
/// Can be used in custom flows. For example:
/// If UpdateInfo.lastAvailableVersion.major > 2 don't do anything.
@immutable
class UpdateData {
  const UpdateData({
    required this.status,
    required this.version,
    required this.updateInfo,
    required this.metadata,
  });

  /// Application [UpdateStatus]
  final UpdateStatus status;

  /// Application [Version]
  final Version version;

  /// Application [UpdateInfo]
  final UpdateInfo updateInfo;

  final Map<String, dynamic> metadata;

  factory UpdateData.fromMap(Map<dynamic, dynamic> map) {
    return UpdateData(
      status: UpdateStatusMapper.map(map[Constants.status]),
      version: Version.fromMap(map[Constants.version]),
      updateInfo: UpdateInfo.fromMap(map[Constants.updateInfo]),
      metadata: _mapMetadata(map[Constants.metadata]),
    );
  }

  static Map<String, dynamic> _mapMetadata(dynamic value) {
    final rawMetadata = value as Map<dynamic, dynamic>;
    return rawMetadata.map((key, value) => MapEntry(key as String, value));
  }
}

/// Data about the application form Google Store.
class QueenOfVersionsUpdateData {
  /// Application version code.
  int versionCode;

  /// Application update priority.
  int updatePriority;

  /// Number of days since the last application version was uploaded to the Store.
  int clientVersionStalenessDays;

  static QueenOfVersionsUpdateData fromMap(Map<dynamic, dynamic> map) {
    final QueenOfVersionsUpdateData data = QueenOfVersionsUpdateData();
    data.clientVersionStalenessDays =
        map[Constants.clientVersionStalenessDays] != null ? map[Constants.clientVersionStalenessDays] : null;
    data.updatePriority = map[Constants.updatePriority] != null ? map[Constants.updatePriority] : null;
    data.versionCode = map[Constants.versionCode] != null ? map[Constants.versionCode] : null;
    return data;
  }
}
