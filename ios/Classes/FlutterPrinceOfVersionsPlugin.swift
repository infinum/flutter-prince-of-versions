import Flutter
import UIKit
import PrinceOfVersions

public class FlutterPrinceOfVersionsPlugin: NSObject, FlutterPlugin {
    static var requirementsChannel: FlutterMethodChannel?

    let dispatchQueue = DispatchQueue(label: Constants.requirementCheck)
    let dispatchGroup = DispatchGroup()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.Flutter.channelName, binaryMessenger: registrar.messenger())
        requirementsChannel = FlutterMethodChannel(name: Constants.Flutter.requirementsChannelName, binaryMessenger: registrar.messenger())
        let instance = FlutterPrinceOfVersionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == Constants.Flutter.checkForUpdatesMethodName) {
            let args = call.arguments as! [Any]
            let url = args[0] as! String
            let shouldPinCertificates = args[1] as! Bool
            let httpHeaderFields = args[2] as! [String: String]
            let requirementChecks = args[3] as! [String]
            checkForUpdates(
                url: url,
                shouldPinCertificates: shouldPinCertificates,
                httpHeaderFields: httpHeaderFields,
                requirementChecks: requirementChecks,
                result: result
            )
        }
        else if (call.method == Constants.Flutter.checkUpdatesFromAppStoreMethodName) {
            let args = call.arguments as! [Any]
            let trackPhaseRelease = args[0] as! Bool
            let notifyOnce = args[1] as! Bool
            checkForUpdatesFromAppStore(
                trackPhaseRelease: trackPhaseRelease,
                notificationFrequency: notifyOnce ? .once : .always,
                result: result
            )
        }

    }

    func checkForUpdates(url: String, shouldPinCertificates: Bool, httpHeaderFields: [String: String], requirementChecks: [String], result: @escaping FlutterResult) {
        guard let povUrl = URL(string: url)
        else {
            result(FlutterError(code: Constants.Error.invalidURLCode,
                                message: Constants.Error.invalidURLMessage,
                                details: nil)
            )
            return
        }

        let povOptions = PoVRequestOptions()
        povOptions.shouldPinCertificates = shouldPinCertificates
        httpHeaderFields.forEach { (key, value) in
            povOptions.set(value: value as NSString, httpHeaderField: key as NSString)
        }

        requirementChecks.forEach { (requirementKey) in
            povOptions.addRequirement(key: requirementKey) { (requirementValue) -> Bool in
                var requirementResult = false

                self.dispatchQueue.async {
                    self.dispatchGroup.enter()
                    FlutterPrinceOfVersionsPlugin.requirementsChannel?.invokeMethod(Constants.Flutter.checkRequirementMethodName,
                                                                               arguments: [requirementKey, requirementValue],
                                                                               result: { (result) in
                        requirementResult = result as! Bool
                        self.dispatchGroup.leave()
                    })
                    self.dispatchGroup.wait(timeout: .distantFuture)
                }

                return requirementResult
            }
        }

        PrinceOfVersions.checkForUpdates(from: povUrl, options: povOptions)  { response in
            switch response.result {
            case .success(let updateResultData):
                let data = UpdateData(status: updateResultData.updateState,
                                      version: updateResultData.updateVersion,
                                      updateInfo: updateResultData.updateInfo,
                                      metadata: updateResultData.metadata)
                result(data.toMap())
            case .failure(let error):
                result(FlutterError(code: "",
                                    message: error.localizedDescription,
                                    details: nil)
                )
            }
        }
    }

    func checkForUpdatesFromAppStore(trackPhaseRelease: Bool,
                                     notificationFrequency: NotificationType,
                                     result: @escaping FlutterResult) {
        PrinceOfVersions.checkForUpdateFromAppStore(trackPhaseRelease: trackPhaseRelease,
                                                    notificationFrequency: notificationFrequency) { response in
            switch response {
            case .success(let appStoreResult):
                let data = AppStoreUpdateData(status: appStoreResult.updateState,
                                              version: appStoreResult.updateVersion,
                                              updateInfo: appStoreResult.updateInfo)
                do {
                    result(try data.asDictionary())
                } catch {
                    result(FlutterError(code: "",
                                        message: Constants.Error.dataParseError,
                                        details: nil)
                    )
                }

            case .failure(let error):
                result(FlutterError(code: "",
                                    message: error.localizedDescription,
                                    details: nil)
                )
            }
        }
    }

}

struct AppStoreUpdateData: Encodable {

    let status: UpdateStatus
    let version: Version
    let appStoreUpdateInfo: AppStoreUpdateInfo

    init(status: UpdateStatus, version: Version, updateInfo: AppStoreUpdateInfo) {
        self.status = status
        self.version = version
        self.appStoreUpdateInfo = updateInfo
    }

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
          throw NSError()
        }
        return dictionary
      }
}

class UpdateData {

    let status: UpdateStatus
    let version: Version
    let updateInfo: UpdateInfo
    let metadata: [String: Any]

    init(status: UpdateStatus, version: Version, updateInfo: UpdateInfo, metadata: [String: Any]?) {
        self.status = status
        self.version = version
        self.updateInfo = updateInfo
        self.metadata = metadata ?? [:]
    }

    func toMap() -> [String: Any] {
        return [Constants.UpdateData.status: status.toString(),
                Constants.UpdateData.version: version.toMap(),
                Constants.UpdateData.updateInfo: updateInfo.toMap(),
                Constants.UpdateData.metadata: metadata]
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

extension UpdateStatus: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch (self) {
        case .noUpdateAvailable: try container.encode(toString())
        case .requiredUpdateNeeded: try container.encode(toString())
        case .newUpdateAvailable: try container.encode(toString())
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
