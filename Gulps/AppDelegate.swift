import UIKit
import WatchConnectivity
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
  var window: UIWindow?
  var realmNotification: RLMNotificationToken?
  let watchConnectivityHelper = WatchConnectivityHelper()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    setupAppearance()
    Settings.registerDefaults()
    watchConnectivityHelper.setupWatchConnectivity(delegate: self)

    let userDefaults = UserDefaults.groupUserDefaults()
    if (!userDefaults.bool(forKey: Constants.General.onboardingShown.key())) {
      loadOnboardingInterface()
    } else {
      loadMainInterface()
      checkVersion()
    }

    return true
  }

  /**
   Check the app version and perform required tasks when upgrading
   */
  func checkVersion() {
    let userDefaults = UserDefaults.groupUserDefaults()
    let current = userDefaults.integer(forKey: "BUNDLE_VERSION")
    if let versionString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let version = Int(versionString) {
      if current < 13 {
        NotificationHelper.rescheduleNotifications()
      }
      userDefaults.set(version, forKey: "BUNDLE_VERSION")
      userDefaults.synchronize()
    }
  }

  /**
   Sets the main appearance of the app
   */
  func setupAppearance() {
    Globals.actionSheetAppearance()

    UIApplication.shared.statusBarStyle = .lightContent

    UITabBar.appearance().tintColor = .palette_main

    if let font = UIFont(name: "KaushanScript-Regular", size: 22) {
      UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white]
    }

    UINavigationBar.appearance().barTintColor = .palette_main
    UINavigationBar.appearance().tintColor = .white

    window?.backgroundColor = .white
  }

  /**
   Present the onboarding controller if needed
   */
  func loadOnboardingInterface() {
    let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
    if let controller = storyboard.instantiateInitialViewController() {
      self.window?.rootViewController = controller
    }
  }

  /**
   Present the main interface
   */
  func loadMainInterface() {
    realmNotification = watchConnectivityHelper.setupWatchUpdates()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let controller = storyboard.instantiateInitialViewController() {
      self.window?.rootViewController = controller
    }
  }

  // MARK: - Notification handler

  func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
    if let identifier = identifier {
      NotificationHelper.handleNotification(notification, identifier: identifier)
    }
    completionHandler()
  }

  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    if (UIApplication.shared.scheduledLocalNotifications?.count == 0) {
      NotificationHelper.registerNotifications()
    }
  }

  // MARK: - 3D Touch shortcut

  enum ShortcutType: String {
    case Big = "it.fancypixel.gulps.big"
    case Small = "it.fancypixel.gulps.small"
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    handleShortcutItem(shortcutItem)
    completionHandler(true)
  }

  func handleShortcutItem(_ item: UIApplicationShortcutItem) {
    if let type = ShortcutType(rawValue: item.type) {
      if (type == .Small) {
        EntryHandler.sharedHandler.addGulp(UserDefaults.groupUserDefaults().double(forKey: Constants.Gulp.small.key()))
      } else if (type == .Big) {
        EntryHandler.sharedHandler.addGulp(UserDefaults.groupUserDefaults().double(forKey: Constants.Gulp.big.key()))
      }
    }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    watchConnectivityHelper.session(session, didReceiveApplicationContext: applicationContext)
  }

  @available(iOS 9.3, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

  }

  @available(iOS 9.3, *)
  public func sessionDidBecomeInactive(_ session: WCSession) {

  }

  @available(iOS 9.3, *)
  public func sessionDidDeactivate(_ session: WCSession) {

  }

}
