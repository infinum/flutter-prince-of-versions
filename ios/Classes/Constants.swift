import Foundation

enum Constants {

    static let requirementCheck = "REQUIREMENT_CHECK"
    
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
        static let metadata = "metadata"
    }

    enum Error {
        static let invalidURLMessage = "Invalid URL"
    }

    enum Flutter {
        static let channelName = "flutter_prince_of_versions"
        static let checkForUpdatesMethodName = "check_for_updates"
        static let checkForUpdatesFromAppStoreMethodName = "check_for_updates_from_app_store"
        
        static let requirementsChannelName = "flutter_prince_of_versions_requirements"
        static let checkRequirementMethodName = "check_requirement"
    }
}
