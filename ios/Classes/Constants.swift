import Foundation

enum Constants {

    enum UpdateStatus {
        static let updateAvailable = "update-available"
        static let noUpdate = "no-update"
        static let requiredUpdate = "required-update"
    }

    enum Version {
        static let major = "major"
        static let minor = "minor"
        static let patch = "patch"
        static let build = "build"
    }

    enum UpdateInfo {
        static let lastVersionAvailable = "lastVersionAvailable"
        static let installedVersion = "installedVersion"
        static let requiredVersion = "requiredVersion"
    }

    enum UpdateData {
        static let status = "status"
        static let version = "version"
        static let updateInfo = "updateInfo"
    }

    enum Error {
        static let invalidJSONCode = "1"
        static let invalidJSONMessage = "Invalid JSON"
        static let invalidURLCode = "2"
        static let invalidURLMessage = "Invalid URL"
    }

    enum Flutter {
        static let channelName = "flutter_prince_of_versions"
        static let checkForUpdatesMethodName = "check_for_updates"
        static let checkUpdatesFromStoreMethodName = "check_updates_from_store"

    }
}
