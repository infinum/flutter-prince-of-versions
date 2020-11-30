import Flutter
import UIKit
import PrinceOfVersions

public class FlutterPrinceOfVersionsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.Flutter.channelName, binaryMessenger: registrar.messenger())
        let instance = FlutterPrinceOfVersionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == Constants.Flutter.checkForUpdatesMethodName) {
            let args = call.arguments as? [Any]
            checkForUpdates(url: args?.first as? String, result: result)
        } else if (call.method == Constants.Flutter.checkUpdatesFromStoreMethodName) {
            checkForUpdatesFromAppStore(result: result)
        }

    }

    func checkForUpdates(url: String?, result: @escaping FlutterResult) {
        guard let apiUrl = url,
              let povUrl = URL(string: apiUrl) else {
            result(FlutterError(code: Constants.Error.invalidURLCode,
                                message: Constants.Error.invalidURLMessage,
                                details: nil)
            )
            return
        }

        PrinceOfVersions.checkForUpdates(from: povUrl) { response in
            switch response.result {
            case .success(let updateResultData):
                let data = UpdateData(status: updateResultData.updateState,
                                      version: updateResultData.updateVersion,
                                      updateInfo: updateResultData.updateInfo)
                result(data.toMap())
            case .failure:
                result(FlutterError(code: Constants.Error.invalidJSONCode,
                                    message: Constants.Error.invalidJSONMessage,
                                    details: nil)
                )
            }
        }
    }

    func checkForUpdatesFromAppStore(result: @escaping FlutterResult) {
        PrinceOfVersions.checkForUpdateFromAppStore(trackPhaseRelease: false) { response in
            switch response {
            case .success(let appStoreResult):
                let data = AppStoreUpdateData(status: appStoreResult.updateState,
                                              version: appStoreResult.updateVersion,
                                              updateInfo: appStoreResult.updateInfo)
                result(data.toMap())

            case .failure:
                result(FlutterError(code: Constants.Error.invalidJSONCode,
                                    message: Constants.Error.invalidJSONMessage,
                                    details: nil)
                )
            }
        }
    }

}

class AppStoreUpdateData {

    let status: UpdateStatus
    let version: Version
    let appStoreUpdateInfo: AppStoreUpdateInfo

    init(status: UpdateStatus, version: Version, updateInfo: AppStoreUpdateInfo) {
        self.status = status
        self.version = version
        self.appStoreUpdateInfo = updateInfo
    }

    func toMap() -> [String: Any] {
        return [Constants.UpdateData.status: status.toString(),
                Constants.UpdateData.version: version.toMap(),
                Constants.UpdateData.updateInfo: appStoreUpdateInfo.toMap()]
    }
}

class UpdateData {

    let status: UpdateStatus
    let version: Version
    let updateInfo: UpdateInfo

    init(status: UpdateStatus, version: Version, updateInfo: UpdateInfo) {
        self.status = status
        self.version = version
        self.updateInfo = updateInfo
    }

    func toMap() -> [String: Any] {
        return [Constants.UpdateData.status: status.toString(),
                Constants.UpdateData.version: version.toMap(),
                Constants.UpdateData.updateInfo: updateInfo.toMap()]
    }
}

extension UpdateStatus {

    func toString() -> String {
        switch self {
        case .newUpdateAvailable:
            return Constants.UpdateStatus
                .updateAvailable
        case .noUpdateAvailable:
            return Constants.UpdateStatus.noUpdate
        case .requiredUpdateNeeded:
            return Constants.UpdateStatus.requiredUpdate
        }
    }

}

extension Version {
    func toMap() -> [String: Any] {
        return [Constants.Version.major: major,
                Constants.Version.minor: minor,
                Constants.Version.patch: patch,
                Constants.Version.build: build]
    }
}

extension UpdateInfo {
    func toMap() -> [String: Any?] {
        return [Constants.UpdateInfo.lastVersionAvailable: lastVersionAvailable?.toMap(),
                Constants.UpdateInfo.installedVersion: installedVersion.toMap(),
                Constants.UpdateInfo.requiredVersion: requiredVersion?.toMap()]
    }
}

extension AppStoreUpdateInfo {
    func toMap() -> [String: Any?] {
        return [Constants.UpdateInfo.lastVersionAvailable: lastVersionAvailable?.toMap(),
                Constants.UpdateInfo.installedVersion: installedVersion.toMap(),]
    }
}
