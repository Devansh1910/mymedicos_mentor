import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase initialization
        FirebaseApp.configure()
        
        // Set delegates for Firebase Messaging and Notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Request user permission for push notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Successfully registered for push notifications")
            } else if let error = error {
                print("Error while requesting notification permissions: \(error.localizedDescription)")
            }
        }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Setup logout notification handler
        setupLogoutNotification()

        if #available(iOS 13.0, *) {
            // For iOS 13+ using SceneDelegate
        } else {
            // For iOS 12 and below, setup the root view controller
            window = UIWindow(frame: UIScreen.main.bounds)
            let navigationController = UINavigationController(rootViewController: GetStartedViewController())
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            window?.overrideUserInterfaceStyle = .light
        }
        
        return true
    }

    // Firebase Messaging delegate: Token handling
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("Failed to retrieve FCM Token")
            return
        }
        print("Firebase registration token: \(fcmToken)")
        // You can send the token to your server here, if required
    }

    // Handle remote notifications registration success
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs device token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken
    }

    // Handle remote notifications registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    private func setupLogoutNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutNotification), name: NSNotification.Name("UserDidLogout"), object: nil)
    }

    @objc func handleLogoutNotification() {
        DispatchQueue.main.async {
            self.window?.rootViewController?.dismiss(animated: true) {
                let navigationController = UINavigationController(rootViewController: GetStartedViewController())
                self.window?.rootViewController = navigationController
            }
        }
    }

    // Subscribe to Firebase topics for notifications
    private func subscribeToTopics() {
        Messaging.messaging().subscribe(toTopic: "NEWS_UPDATES") { error in
            if let error = error {
                print("Failed to subscribe to NEWS_UPDATES: \(error.localizedDescription)")
            } else {
                print("Subscribed to NEWS_UPDATES topic successfully")
            }
        }
        Messaging.messaging().subscribe(toTopic: "PUBLICATIONS") { error in
            if let error = error {
                print("Failed to subscribe to PUBLICATIONS: \(error.localizedDescription)")
            } else {
                print("Subscribed to PUBLICATIONS topic successfully")
            }
        }
    }
}
