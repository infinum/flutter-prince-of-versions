import Flutter
import UIKit

// TODO:
// - better error handling

public class FlutterPrinceOfVersionsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_prince_of_versions", binaryMessenger: registrar.messenger())
        let instance = FlutterPrinceOfVersionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let rawMethod = Int(call.method) else {
//            return result(FlutterMethodNotImplemented)
//        }

        result("maroje")

    }
}
