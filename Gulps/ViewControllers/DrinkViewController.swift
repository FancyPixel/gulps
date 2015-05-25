import UIKit
import DPMeterView
import UICountingLabel
import Realm

public class DrinkViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet public weak var progressMeter: DPMeterView!
    @IBOutlet public weak var percentageLabel: UICountingLabel!
    @IBOutlet public weak var addButton: UIButton!
    @IBOutlet public weak var smallButton: UIButton!
    @IBOutlet public weak var largeButton: UIButton!
    @IBOutlet public weak var minusButton: UIButton!
    @IBOutlet public var entryHandler: EntryHandler!
    public var userDefaults = NSUserDefaults.groupUserDefaults()
    var expanded = false
    var realmToken: RLMNotificationToken?

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Drink!"

        initAnimation()

        percentageLabel.animationDuration = 1.5
        percentageLabel.format = "%d%%";
        progressMeter.startGravity()

        realmToken = RLMRealm.defaultRealm().addNotificationBlock { note, realm in
            self.updateUI()
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressMeter.setShape(ProgressMeter.pathFromRect(self.progressMeter.frame))
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func updateCurrentEntry(delta: Double) {
        entryHandler.addGulp(delta)
    }

    func updateUI() {
        let percentage = self.entryHandler.currentEntry().percentage
        percentageLabel.countFromCurrentValueTo(Float(round(percentage)))
        if (!progressMeter.isAnimating) {
            progressMeter.setProgress(CGFloat(percentage / 100.0), duration: 1.5)
        }
    }

    @IBAction func addButtonAction(sender: UIButton) {
        if (expanded) {
            contractAddButton()
        } else {
            expandAddButton()
        }
    }

    @IBAction public func selectionButtonAction(sender: UIButton) {
        contractAddButton()
        Globals.showPopTipOnceForKey("UNDO_HINT", userDefaults: userDefaults,
            popTipText: "Tap here to undo your latest action",
            inView: view,
            fromFrame: minusButton.frame)
        let portion = smallButton == sender ? Settings.Gulp.Small.key() : Settings.Gulp.Big.key()
        updateCurrentEntry(userDefaults.doubleForKey(portion))
    }

    @IBAction func removeGulpAction() {
        let alert = UIAlertView(title: "Undo", message: "Undo latest action?", delegate: self, cancelButtonTitle:"No", otherButtonTitles:"Yes")
        alert.show()
    }

    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex > 0) {
            entryHandler.removeLastGulp()
        }
    }
}
