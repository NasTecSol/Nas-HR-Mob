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

        GeneratedPluginRegistrant.register(with: self)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

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
        // PUSH NOTIFICATIONS SETUP
        // ---------------------------
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self

        return result
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

    override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("Firebase registration token: \(deviceToken)")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}
