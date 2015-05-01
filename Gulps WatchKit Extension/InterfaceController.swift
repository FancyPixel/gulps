import WatchKit
import Foundation
import Realm

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    @IBOutlet weak var progressImage: WKInterfaceImage!

    let entryHandler = EntryHandler()
    var realmToken: RLMNotificationToken?
    var previousPercentage = 0.0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        EntryHandler.bootstrapRealm()
        
        realmToken = RLMRealm.defaultRealm().addNotificationBlock { note, realm in
            self.reloadAndUpdateUI()
        }

        let entry = EntryHandler().currentEntry() as Entry
        previousPercentage = entry.percentage
        progressImage.setImageNamed("activity-")
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {

    }

    @IBAction func addSmallGulpAction() {
        updateWithGulp(Settings.Gulp.Small.key())
    }

    @IBAction func addBigGulpAction() {
        updateWithGulp(Settings.Gulp.Big.key())
    }

    override func willActivate() {
        super.willActivate()
        reloadAndUpdateUI()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}

// MARK: Private Helper Methods

private extension InterfaceController {
    
    func reloadAndUpdateUI() {
        let entry = EntryHandler().currentEntry() as Entry
        var delta = Int(entry.percentage - previousPercentage)
        if (delta < 0) {
            // animate in reverse using negative duration
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(entry.percentage), -delta), duration: -1.0, repeatCount: 1)
        } else {
            if (delta == 0) {
                // if the range's length is 0, no image is loaded
                delta = 1
            }
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
        }
        goalLabel.setText("DAILY GOAL: \(entry.formattedPercentage())")
        previousPercentage = entry.percentage
    }
    
    func updateWithGulp(gulp: String) {
        entryHandler.addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(gulp))
        reloadAndUpdateUI()
    }
}
