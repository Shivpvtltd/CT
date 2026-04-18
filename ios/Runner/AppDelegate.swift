import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let dnsChannel = "com.shieldx.app/dns"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        let channel = FlutterMethodChannel(
            name: dnsChannel,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "startDns":
                result(true)
            case "stopDns":
                result(true)
            case "getDnsStatus":
                result(false)
            case "pingDns":
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
