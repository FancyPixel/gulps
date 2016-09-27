import WatchKit
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
  }()

  func applicationDidFinishLaunching() {
    setupWatchConnectivity()
    setupNotificationCenter()
  }

  // MARK: - Notification Center

  fileprivate func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationWatchGulpAdded), object: nil, queue: nil) {
      (notification: Notification) in
      self.sendApplicationContext()
      self.reloadComplications()
    }
  }

  // MARK: - Watch Connectivity

  fileprivate func setupWatchConnectivity() {
    guard WCSession.isSupported() else {
      return
    }

    let session  = WCSession.default()
    session.delegate = self
    session.activate()
  }

  fileprivate func sendApplicationContext() {
    guard WCSession.isSupported() else {
      return
    }

    do {
      let context = WatchEntryHelper.sharedHelper.applicationContext()
      try WCSession.default().updateApplicationContext(context)
    } catch {
      print("Unable to send cache data to WCSession: \(error)")
    }
  }

  @available(watchOS 2.2, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let goal = applicationContext[Constants.Gulp.goal.key()] as? Double,
      let current = applicationContext[Constants.WatchContext.current.key()] as? Double,
      let small = applicationContext[Constants.Gulp.small.key()] as? Double,
      let big = applicationContext[Constants.Gulp.big.key()] as? Double {
      WatchEntryHelper.sharedHelper.saveSettings(goal: goal, current: current, small: small, big: big)
      NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationContextReceived), object: nil)
      self.reloadComplications()
    }
  }

  func reloadComplications() {
    DispatchQueue.main.async {
      if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
        complications.forEach({
          (complication: CLKComplication) in
          CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
        })
      }
    }
  }
}
