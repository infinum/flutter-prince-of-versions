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
    final latestVersionAvailableMap = map[Constants.lastVersionAvailable];
    final requiredVersionMap = map[Constants.requiredVersion];

    return UpdateInfo(
      lastVersionAvailable: latestVersionAvailableMap != null ? Version.fromMap(latestVersionAvailableMap) : null,
      installedVersion: Version.fromMap(map[Constants.installedVersion]),
      requiredVersion: requiredVersionMap != null ? Version.fromMap(requiredVersionMap) : null,
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
@immutable
class QueenOfVersionsUpdateData {
  const QueenOfVersionsUpdateData({
    this.versionCode,
    this.updatePriority,
    this.clientVersionStalenessDays,
  });

  /// Application version code.
  final int? versionCode;

  /// Application update priority.
  final int? updatePriority;

  /// Number of days since the last application version was uploaded to the Store.
  final int? clientVersionStalenessDays;

  factory QueenOfVersionsUpdateData.fromMap(Map<dynamic, dynamic> map) {
    return QueenOfVersionsUpdateData(
      versionCode: map[Constants.versionCode] as int?,
      updatePriority: map[Constants.updatePriority] as int?,
      clientVersionStalenessDays: map[Constants.clientVersionStalenessDays] as int?,
    );
  }
}
