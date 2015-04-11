import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GAI.sharedInstance().trackerWithTrackingId("UA-XXXXXXXX-X")
        GAI.sharedInstance().trackUncaughtExceptions = true

        DPMeterView.appearance().trackTintColor = UIColor.lightGray()
        DPMeterView.appearance().progressTintColor = UIColor.mainColor()

        Globals.actionSheetAppearance()
        
        UITabBar.appearance().tintColor = UIColor.mainColor()

        let font = UIFont(name: "KaushanScript-Regular", size: 22)
        if let font = font {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }

        UINavigationBar.appearance().barTintColor = UIColor.mainColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

        Settings.registerDefaults()

        let userDefaults = NSUserDefaults.groupUserDefaults()
        if (!userDefaults.boolForKey(Settings.General.OnboardingShown.key())) {
            loadOnboardingInterface()
        } else {
            loadMainInterface()
        }

        return true
    }

    func loadOnboardingInterface() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UIViewController
        self.window?.rootViewController = controller
    }

    func loadMainInterface() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UIViewController
        self.window?.rootViewController = controller
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let identifier = identifier {
            NotificationHelper.handleNotification(notification, identifier: identifier)
        }
        completionHandler()
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if (UIApplication.sharedApplication().scheduledLocalNotifications.count == 0) {
            NotificationHelper.registerNotifications()
        }
    }
}

