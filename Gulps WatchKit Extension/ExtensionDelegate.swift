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
        notificationCenter.addObserverForName(NotificationWatchGulpAdded, object: nil, queue: nil) {
            (notification: NSNotification) in
            if let data = notification.object as? String {
                let cache = EntryHelper.sharedHelper.cachedData(newData: data)
                self.sendCachedData(cache)
            }
        }
    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session  = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    private func sendCachedData(data: [[String: AnyObject]]) {
        if WCSession.isSupported() {
            do {
                let dictionary = [Constants.WatchContext.Cached.key(): data]
                try WCSession.defaultSession().updateApplicationContext(dictionary)
            } catch {
                print("Unable to send cache data to WCSession: \(error)")
            }
        }
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Receiving Context: \(applicationContext)")
        if let goal = applicationContext[Constants.Gulp.Goal.key()] as? Double,
            let current = applicationContext[Constants.WatchContext.Current.key()] as? Double,
            let small = applicationContext[Constants.Gulp.Small.key()] as? Double,
            let big = applicationContext[Constants.Gulp.Big.key()] as? Double {
                EntryHelper.sharedHelper.saveSettings(goal: goal, current: current, small: small, big: big)
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationContextReceived, object: nil)
                }
        }
    }

}
