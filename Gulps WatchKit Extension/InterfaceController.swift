import WatchKit
import Foundation
import WatchConnectivity

let NotificationContextReceived = "NotificationContextReceived"
let NotificationWatchGulpAdded = "NotificationWatchGulpAdded"

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    @IBOutlet weak var progressImage: WKInterfaceImage!
    lazy var notificationCenter: NSNotificationCenter = {
        return NSNotificationCenter.defaultCenter()
    }()
    var previousPercentage = 0.0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setupNotificationCenter()

        progressImage.setImageNamed("activity-")
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
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
        updateWithGulp(Constants.Gulp.Small.key())
    }

    @IBAction func addBigGulpAction() {
        updateWithGulp(Constants.Gulp.Big.key())
    }

    // MARK: - Notification Center

    private func setupNotificationCenter() {
        notificationCenter.addObserverForName(NotificationContextReceived, object: nil, queue: nil) { _ in
            self.reloadAndUpdateUI()
        }
    }
}

// MARK: - Private Helper Methods

typealias InterfaceHelper = InterfaceController
private extension InterfaceHelper {

    func reloadAndUpdateUI() {
        if NSUserDefaults.standardUserDefaults().doubleForKey(Constants.Gulp.Goal.key()) == 0 {
            progressImage.setHidden(true)
            goalLabel.setText(NSLocalizedString("watch.please_onboard", comment: "Shown when the user did not start the iPhone app yet"))
            return
        }

        progressImage.setHidden(false)

        var percentage = WatchEntryHelper.sharedHelper.percentage() ?? 0
        if percentage > 100 {
            percentage = 100
        }
        var delta = percentage - Int(previousPercentage)
        if (delta < 0) {
            // animate in reverse using negative duration
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(percentage, -delta), duration: -1.0, repeatCount: 1)
        } else {
            if (delta == 0) {
                // if the range's length is 0, no image is loaded
                delta = 1
            }
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
        }
        goalLabel.setText("\(NSLocalizedString("daily goal:", comment: "")) \(percentage)%")
        previousPercentage = Double(percentage)
    }

    func updateWithGulp(gulp: String) {
        WatchEntryHelper.sharedHelper.addGulp(gulp)
        reloadAndUpdateUI()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationWatchGulpAdded, object: gulp)
    }
}

