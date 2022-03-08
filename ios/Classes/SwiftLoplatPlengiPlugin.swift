import Flutter
import UIKit
import MiniPlengi

public class SwiftLoplatPlengiPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "loplat_plengi", binaryMessenger: registrar.messenger())
        let instance = SwiftLoplatPlengiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
        case "getPlatformVersion":
          result("iOS")
        case "getEngineStatus":
          result(Plengi.getEngineStatus().rawValue)
        case "start":
          result(Plengi.start().rawValue)
        case "stop":
          result(Plengi.stop().rawValue)
        case "enableAdNetwork":
          guard let arg = call.arguments as? [Bool] else {
              result(FlutterError(code: call.method, message: "no argument", details: nil))
              return
          }
          if arg.count == 2 {
              let enableAd = arg[0]
              let enableNoti = arg[1]
              result(String(Plengi.enableAdNetwork(enableAd, enableNoti: enableNoti).rawValue))
          } else {
              result(FlutterError(code: call.method, message: "invalid argument size", details: nil))
          }
        case "setEchoCode":
            result("success")
        case "enableTestServer":
            result("success")
        case "TEST_refreshPlace_foreground":
            Plengi.manual_refreshPlace_foreground()
            result("success")
        case "requestAlwaysAuthorization":
            Plengi.requestAlwaysLocationAuthorization()
            result("success")
        default:
            result(FlutterMethodNotImplemented)
      }
  }
}

 //else if (call.method.equals("TEST_refreshPlace_foreground")) {
//      try {
//        Plengi.getInstance(mContext).TEST_refreshPlace_foreground(new OnPlengiListener() {
//          @Override
//          public void onSuccess(PlengiResponse response) {
//            result.success(new Gson().toJson(response));
//          }
//
//          @Override
//          public void onFail(PlengiResponse response) {
//            result.success(new Gson().toJson(response));
//          }
//        });
//      } catch (Exception ex) {
//        result.error("1", ex.getMessage(), ex.getStackTrace());
//      }
//    } else {
//      result.notImplemented();
//    }
