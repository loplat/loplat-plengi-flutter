import Flutter
import UIKit
import MiniPlengi

public class LoplatPlengiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "loplat_plengi", binaryMessenger: registrar.messenger())
    let instance = LoplatPlengiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
        
    case "initialize":
            if let args = call.arguments as? Dictionary<String, Any>,
                  let id = args["id"] as? String, let pw = args["pw"] as? String {
                result(Plengi.initialize(clientID: id, clientSecret: pw))
                } else {
                  result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
                }
    case "start":
        result(Plengi.start().rawValue)
    case "stop":
        result(Plengi.stop().rawValue)
    case "requestAlwaysLocationAuthorization":
        Plengi.requestAlwaysLocationAuthorization()
        result("success")
    case "requestAlwaysAuthorization":
        Plengi.requestTrackingAuthorization {
            result("success")
        }
        result("success")
    case "enableAdNetwork":
        guard let arg = call.arguments as? [Bool] else {
                  result(FlutterError(code: call.method, message: "no argument", details: nil))
                  return
              }
              if arg.count == 2 {
                  let enableAd: Bool = arg[0]
                  let enableNoti: Bool = arg[1]
                  result(Plengi.enableAdNetwork(enableAd, enableNoti: enableNoti).rawValue == 0 ? "success":"fail")
              } else {
                  result(FlutterError(code: call.method, message: "invalid argument size", details: nil))
              }
    case "getEngineStatus":
        result(Plengi.getEngineStatus().rawValue)
    case "manual_refreshPlace_foreground":
        result(Plengi.manual_refreshPlace_foreground().rawValue)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
