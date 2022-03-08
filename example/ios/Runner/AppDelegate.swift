import UIKit
import Flutter
import MiniPlengi

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PlaceDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      Plengi.initialize(clientID: "loplat", clientSecret: "loplatsecret")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func responsePlaceEvent(_ plengiResponse: PlengiResponse) {
        print(plengiResponse)
    }
}
