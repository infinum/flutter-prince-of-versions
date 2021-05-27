part of flutter_prince_of_versions;

/// Application update status.
enum UpdateStatus {
  /// Application update is available.
  newUpdateAvailable,

  /// Application update is not available.
  noUpdateAvailable,

  /// Application updates is available, the user should install it before using the application.
  requiredUpdateNeeded,
}

class _UpdateStatusMapper {
  _UpdateStatusMapper._();

  static UpdateStatus map(dynamic value) {
    final rawUpdateStatus = value as String;
    switch (rawUpdateStatus) {
      case Constants.newUpdateAvailable:
        return UpdateStatus.newUpdateAvailable;
      case Constants.noUpdateAvailable:
        return UpdateStatus.noUpdateAvailable;
      case Constants.requiredUpdateNeeded:
        return UpdateStatus.requiredUpdateNeeded;
    }
    throw Error();
  }
}

/// Information about application and its updates.
@immutable
class UpdateInfo {
  const UpdateInfo({
    this.lastVersionAvailable,
    required this.installedVersion,
    this.requiredVersion,
  });

  /// Last version of the application.
  final Version? lastVersionAvailable;

  /// Current installed application version.
  final Version installedVersion;

  /// Minimum required version of the application.
  final Version? requiredVersion;

  factory UpdateInfo._fromMap(Map<dynamic, dynamic> map) {
    final rawLatestVersionAvailable = map[Constants.lastVersionAvailable];
    final rawInstalledVersion = map[Constants.installedVersion];
    final rawRequiredVersion = map[Constants.requiredVersion];

    return UpdateInfo(
      lastVersionAvailable: rawLatestVersionAvailable != null
          ? Version._fromMap(rawLatestVersionAvailable)
          : null,
      installedVersion: Version._fromMap(rawInstalledVersion),
      requiredVersion: rawRequiredVersion != null
          ? Version._fromMap(rawRequiredVersion)
          : null,
    );
  }
}

/// Application Version information.
@immutable
class Version {
  const Version({
    required this.major,
    this.minor,
    this.patch,
    this.build,
  });

  /// Application major version number. iOS and Android.
  final int major;

  /// Application minor version number. iOS only.
  final int? minor;

  /// Application patch version number. iOS only.
  final int? patch;

  /// Application build version number. iOS only.
  final int? build;

  factory Version._fromMap(Map<dynamic, dynamic> map) {
    return Version(
      major: map[Constants.major] as int,
      minor: map[Constants.minor] as int?,
      patch: map[Constants.patch] as int?,
      build: map[Constants.build] as int?,
    );
  }

  String toString() {
    var s = [major, minor, patch].whereType<int>().join('.');
    if (build != null) {
      s += ':$build';
    }
    return s;
  }
}

/// Application update information.
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

  factory UpdateData._fromMap(Map<dynamic, dynamic> map) {
    return UpdateData(
      status: _UpdateStatusMapper.map(map[Constants.status]),
      version: Version._fromMap(map[Constants.version]),
      updateInfo: UpdateInfo._fromMap(map[Constants.updateInfo]),
      metadata: _mapMetadata(map[Constants.metadata]),
    );
  }

  static Map<String, dynamic> _mapMetadata(dynamic value) {
    final rawMetadata = value as Map<dynamic, dynamic>;
    return rawMetadata.map((key, value) => MapEntry(key as String, value));
  }
}

/// Application update information, obtained from Google Play.
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

  /// Number of days since the last application version was uploaded to Google Play.
  final int? clientVersionStalenessDays;

  factory QueenOfVersionsUpdateData._fromMap(Map<dynamic, dynamic> map) {
    return QueenOfVersionsUpdateData(
      versionCode: map[Constants.versionCode] as int?,
      updatePriority: map[Constants.updatePriority] as int?,
      clientVersionStalenessDays:
          map[Constants.clientVersionStalenessDays] as int?,
    );
  }
}
