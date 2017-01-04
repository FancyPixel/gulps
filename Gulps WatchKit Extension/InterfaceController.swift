import WatchKit
import Foundation
import WatchConnectivity

let NotificationContextReceived = "NotificationContextReceived"
let NotificationWatchGulpAdded = "NotificationWatchGulpAdded"

class InterfaceController: WKInterfaceController, WCSessionDelegate {

  @IBOutlet weak var goalLabel: WKInterfaceLabel!
  @IBOutlet weak var progressImage: WKInterfaceImage!
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
  }()
  var previousPercentage = 0.0

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    setupNotificationCenter()

    progressImage.setImageNamed("activity-")
  }

  override func handleAction(withIdentifier identifier: String?, for localNotification: UILocalNotification) {
    reloadAndUpdateUI()
  }

  override func willActivate() {
    super.willActivate()
    reloadAndUpdateUI()
  }

  override func didDeactivate() {
    super.didDeactivate()
    notificationCenter.removeObserver(self)
  }

  //MARK: - Actions

  @IBAction func addSmallGulpAction() {
    updateWithGulp(Constants.Gulp.small.key())
  }

  @IBAction func addBigGulpAction() {
    updateWithGulp(Constants.Gulp.big.key())
  }

  // MARK: - Notification Center

  fileprivate func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationContextReceived), object: nil, queue: nil) { _ in
      self.reloadAndUpdateUI()
    }
  }

  @available(watchOS 2.2, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

  }
}

// MARK: - Private Helper Methods

typealias InterfaceHelper = InterfaceController
private extension InterfaceHelper {

  func reloadAndUpdateUI() {
    if UserDefaults.standard.double(forKey: Constants.Gulp.goal.key()) == 0 {
      progressImage.setHidden(true)
      goalLabel.setText(NSLocalizedString("watch.please_onboard", comment: "Shown when the user did not start the iPhone app yet"))
      return
    }

    progressImage.setHidden(false)

    let percentage = WatchEntryHelper.sharedHelper.percentage() ?? 0
    var delta = (percentage > 100 ? 100 : percentage) - Int(previousPercentage)
    if (delta < 0) {
      // animate in reverse using negative duration
      progressImage.startAnimatingWithImages(in: NSMakeRange(percentage, -delta), duration: -1.0, repeatCount: 1)
    } else {
      if (delta == 0) {
        // if the range's length is 0, no image is loaded
        delta = 1
      }
      progressImage.startAnimatingWithImages(in: NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
    }
    goalLabel.setText("\(NSLocalizedString("daily goal:", comment: "")) \(percentage)%")
    previousPercentage = Double(percentage)
  }

  func updateWithGulp(_ gulp: String) {
    WatchEntryHelper.sharedHelper.addGulp(gulp)
    reloadAndUpdateUI()
    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationWatchGulpAdded), object: gulp)
  }
}

