import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    lazy var notificationCenter: NSNotificationCenter = {
        return NSNotificationCenter.defaultCenter()
    }()

    func applicationDidFinishLaunching() {
        setupWatchConnectivity()
        setupNotificationCenter()
    }

    // MARK: - Notification Center

    private func setupNotificationCenter() {

    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session  = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Receiving Context: \(applicationContext)")
        if let goal = applicationContext["goal"] as? Double,
            let current = applicationContext["current"] as? Double,
            let small = applicationContext["small"] as? Double,
            let big = applicationContext["big"] as? Double {
                EntryHelper.sharedHelper.saveSettings(goal: goal, current: current, small: small, big: big)
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationContextReceived, object: nil)
                }
        }
    }

}
