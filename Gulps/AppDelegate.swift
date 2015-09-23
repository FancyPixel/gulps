import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        setupAppearance()
        Settings.registerDefaults()

        let userDefaults = NSUserDefaults.groupUserDefaults()
        if (!userDefaults.boolForKey(Constants.General.OnboardingShown.key())) {
            loadOnboardingInterface()
        } else {
            loadMainInterface()
            checkVersion()
        }

        return true
    }

    func checkVersion() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        let current = userDefaults.integerForKey("BUNDLE_VERSION")
        if let versionString = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String, let version = Int(versionString) {
            if current < 13 {
                NotificationHelper.rescheduleNotifications()
            }
            userDefaults.setInteger(version, forKey: "BUNDLE_VERSION")
            userDefaults.synchronize()
        }
    }

    func setupAppearance() {
        Globals.actionSheetAppearance()

        UITabBar.appearance().tintColor = .mainColor()

        let font = UIFont(name: "KaushanScript-Regular", size: 22)
        if let font = font {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        
        UINavigationBar.appearance().barTintColor = .mainColor()
        UINavigationBar.appearance().tintColor = .whiteColor()

        window?.backgroundColor = .whiteColor()
    }

    func loadOnboardingInterface() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            self.window?.rootViewController = controller
        }
    }

    func loadMainInterface() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            self.window?.rootViewController = controller
        }
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let identifier = identifier {
            NotificationHelper.handleNotification(notification, identifier: identifier)
        }
        completionHandler()
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if (UIApplication.sharedApplication().scheduledLocalNotifications?.count == 0) {
            NotificationHelper.registerNotifications()
        }
    }
}
