import Flutter
import UIKit

final class FlutterCoordinator {
    static let shared = FlutterCoordinator()

    private let engine = FlutterEngine(name: "main_engine")
    private var isRunning = false

    private init() {}

    func warmUp() {
        guard !isRunning else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.example.hybrid/native_bridge",
            binaryMessenger: engine.binaryMessenger
        )
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getInitialPayload":
                result("iOS native передал пользователя demo-user-42")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        engine.run()
        isRunning = true
    }

    func makeFlutterViewController() -> FlutterViewController {
        warmUp()
        return FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }
}
