import UIKit
import FirebaseMessaging
import FirebaseCore
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // FIX: Ensure FlutterViewController exists before channel
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }

        // ---------------------------
        // ENVIRONMENT CHANNEL
        // ---------------------------
        let controller = window?.rootViewController as? FlutterViewController
        if let controller = controller {
            let channel = FlutterMethodChannel(
                name: "env_channel",
                binaryMessenger: controller.binaryMessenger
            )

            channel.setMethodCallHandler { (call, result) in
                if call.method == "isTestFlight" {
                    result(self.isTestFlightBuild())
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        // ---------------------------
        // YOUR ORIGINAL CODE (UNCHANGED)
        // ---------------------------
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    // ---------------------------
    // DETECT TESTFLIGHT
    // ---------------------------
    func isTestFlightBuild() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #endif

        guard let url = Bundle.main.appStoreReceiptURL else {
            return false
        }

        return url.lastPathComponent == "sandboxReceipt"
    }


    // ---------------------------
    // YOUR ORIGINAL METHODS
    // ---------------------------
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }

    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Firebase registration token: \(deviceToken)")
    }
}
