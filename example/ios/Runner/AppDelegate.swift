import Flutter
import UIKit
import MiniPlengi

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        // ********** 중간 생략 ********** //
        Plengi.initialize(clientID: "loplat", clientSecret: "loplatsecret")
        
        if Plengi.setDelegate(self) == .SUCCESS {
            // setDelegate 등록 성공
        } else {
            // setDelegate 등록 실패
        }
        if #available(iOS  10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override  func userNotificationCenter(_ center: UNUserNotificationCenter,
                                          didReceive response: UNNotificationResponse,
                                          withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = Plengi.processLoplatAdvertisement(center,
                                              didReceive: response,
                                              withCompletionHandler: completionHandler)
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension AppDelegate: PlaceDelegate {
    func plengiAlert(_ message: String) {
        //        placeEventLocalNotification(place: message)
    }
    
    private func placeEventType(_ event: PlaceEvent) -> String {
        switch (event) {
        case .ENTER:
            return "[ENTER]"
        case .NEARBY:
            return "[NEAR]"
        case .LEAVE:
            return "[LEAVE]"
        default:
            return ""
        }
    }
    
    func responsePlaceEvent(_ plengiResponse: PlengiResponse) {
        if plengiResponse.echoCode != nil {
            // 고객사에서 설정한 echoCode
        }
        
        if plengiResponse.result == .SUCCESS {
            if plengiResponse.place != nil {
                if plengiResponse.placeEvent == .ENTER {
                    NSLog("place response ENTER: \(plengiResponse.place!.address)")
                    // PlaceEvent가 ENTER 일 경우, 들어온 장소 정보 객체가 넘어옴
                } else if plengiResponse.placeEvent == .NEARBY {
                    NSLog("place response NEARBY: \(plengiResponse.place!.address)")
                    // PlaceEvent가 NEARBY 일 경우, NEARBY 로 인식된 장소 정보가 넘어옴
                }
            }
            
            if plengiResponse.advertisement != nil {
                // loplat X 광고 정보가 있을 때
                // 기본으로 Plengi SDK에서 광고이벤트를 직접 알림으로 처리합니다.
                // 하지만 설정값에 따라 광고이벤트를 직접 처리할 경우 해당 객체를 사용합니다.
            }
        } else {
            /* 여기서부터는 오류인 경우입니다 */
            // plengiResponse.errorReason 에 위치 인식 실패 / 오류 이유가 포함됨
            
            // FAIL : 위치 인식 실패
            // NETWORK_FAIL : 네트워크 오류
            // ERROR_CLOUD_ACCESS : 클라이언트 ID/PW가 틀렸거나 인증되지 않은 사용자가 요청했을 때
            // Location Acquisition Fail : plengiResponse.location에서 위경도 값만 있는 경우
        }
    }
}
