import WatchKit
import WatchConnectivity
import ClockKit

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
            self.sendApplicationContext()
            self.reloadComplications()
        }
    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            return
        }

        let session  = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }

    private func sendApplicationContext() {
        guard WCSession.isSupported() else {
            return
        }

        do {
            let context = WatchEntryHelper.sharedHelper.applicationContext()
            try WCSession.defaultSession().updateApplicationContext(context)
        } catch {
            print("Unable to send cache data to WCSession: \(error)")
        }
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let goal = applicationContext[Constants.Gulp.Goal.key()] as? Double,
            let current = applicationContext[Constants.WatchContext.Current.key()] as? Double,
            let small = applicationContext[Constants.Gulp.Small.key()] as? Double,
            let big = applicationContext[Constants.Gulp.Big.key()] as? Double {
                WatchEntryHelper.sharedHelper.saveSettings(goal: goal, current: current, small: small, big: big)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationContextReceived, object: nil)
                self.reloadComplications()
        }
        
        // NOTE: The Apple Watch target does not yet support "Constants.Gulp.Custom.key"
    }

    func reloadComplications() {
        dispatch_async(dispatch_get_main_queue()) {
            if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
                complications.forEach({
                    (complication: CLKComplication) in
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                })
            }
        }
    }
}
