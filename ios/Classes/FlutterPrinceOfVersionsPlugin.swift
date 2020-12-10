import Flutter
import UIKit
import PrinceOfVersions

public class FlutterPrinceOfVersionsPlugin: NSObject, FlutterPlugin {
    static var flutterChannel: FlutterMethodChannel?

    let dispatchQueue = DispatchQueue(label: Constants.requirementCheck)
    let dispatchGroup = DispatchGroup()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.Flutter.channelName, binaryMessenger: registrar.messenger())
        flutterChannel = FlutterMethodChannel(name: Constants.Flutter.requirementsChannelName, binaryMessenger: registrar.messenger())
        let instance = FlutterPrinceOfVersionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == Constants.Flutter.checkForUpdatesMethodName) {
            let args = call.arguments as? [Any]
            let requestOptions = args?.last as? [String]
            let shouldPinCertificates = args?[1] as? Bool
            let httpHeaderFields = args?[2] as? [String: String]
            let url = args?.first as? String
            checkForUpdates(url: url,
                            shouldPinCertificates: shouldPinCertificates,
                            httpHeaderFields: httpHeaderFields,
                            requestOptions: requestOptions,
                            result: result)
        }
        else if (call.method == Constants.Flutter.checkUpdatesFromStoreMethodName) {
            let args = call.arguments as? [Bool]
            let trackPhaseRelease = args?.first ?? false
            let notificationFrequency = args?.last ?? false
            checkForUpdatesFromAppStore(trackPhaseRelease: trackPhaseRelease,
                                        notificationFrequency: notificationFrequency ? .once : .always,
                                        result: result)
        }

    }

    func checkForUpdates(url: String?, shouldPinCertificates: Bool?, httpHeaderFields: [String: String]?, requestOptions: [String]?, result: @escaping FlutterResult) {
        guard let apiUrl = url,
              let povUrl = URL(string: apiUrl)
        else {
            result(FlutterError(code: Constants.Error.invalidURLCode,
                                message: Constants.Error.invalidURLMessage,
                                details: nil)
            )
            return
        }

        let povOptions = PoVRequestOptions()
        povOptions.shouldPinCertificates = shouldPinCertificates ?? false
        httpHeaderFields?.forEach { (key, value) in
            povOptions.set(value: value as NSString, httpHeaderField: key as NSString)
        }

        requestOptions?.forEach { (key) in
            povOptions.addRequirement(key: key) { (apiValue) -> Bool in
                var requirementResult = false

                self.dispatchQueue.async {
                    self.dispatchGroup.enter()
                    FlutterPrinceOfVersionsPlugin.flutterChannel?.invokeMethod(Constants.Flutter.requirementsMethodName, arguments: [key, apiValue], result: { (result) in
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
                } catch {}

            case .failure(let error):
                // handle error better
                result(FlutterError(code: Constants.Error.invalidJSONCode,
                                    message: Constants.Error.invalidJSONMessage,
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

    enum CodingKeys: String, CodingKey {
           case status
           case version
           case appStoreUpdateInfo
    }

    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status.toString(), forKey: .status)
            try container.encode(appStoreUpdateInfo, forKey: .appStoreUpdateInfo)
            try container.encode(version, forKey: .version)
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
