import Flutter
import UIKit
import MiniPlengi

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      // ********** 중간 생략 ********** //
    Plengi.initialize(clientID: "loplat", clientSecret: "loplatsecret")
               
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
