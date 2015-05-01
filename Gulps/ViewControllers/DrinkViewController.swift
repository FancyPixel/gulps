import UIKit
import DPMeterView
import UICountingLabel
import MMWormhole
import AMPopTip

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
    var wormhole: MMWormhole?

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Drink!"

        initAnimation()

        percentageLabel.animationDuration = 1.5
        percentageLabel.format = "%d%%";
        progressMeter.startGravity()


        wormhole = MMWormhole(applicationGroupIdentifier: "group.\(Constants.bundle())", optionalDirectory: "biggulp")
        wormhole!.listenForMessageWithIdentifier("watchUpdate") { (_) -> Void in
            self.updateUI()
        }
        wormhole!.listenForMessageWithIdentifier("todayUpdate") { (_) -> Void in
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
        wormhole!.passMessageObject("update", identifier: "mainUpdate")
        updateUI()
    }

    func updateUI() {
        let percentage = self.entryHandler.currentEntry().percentage
        percentageLabel.countFromCurrentValueTo(Float(round(percentage)))
        progressMeter.setProgress(CGFloat(percentage / 100.0), duration: 1.5)
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
        if (!userDefaults.boolForKey("UNDO_HINT")) {
            userDefaults.setBool(true, forKey: "UNDO_HINT")
            userDefaults.synchronize()
            AMPopTip.appearance().popoverColor = .mainColor()
            AMPopTip.appearance().offset = 10
            let popTip = AMPopTip()
            popTip.showText("Tap here to undo your latest action", direction: .Down, maxWidth: 200, inView: self.view, fromFrame: self.minusButton.frame)
        }
        if (smallButton == sender) {
            updateCurrentEntry(userDefaults.doubleForKey(Settings.Gulp.Small.key()))
        } else {
            updateCurrentEntry(userDefaults.doubleForKey(Settings.Gulp.Big.key()))
        }
    }

    @IBAction func removeGulpAction() {
        let alert = UIAlertView(title: "Undo", message: "Undo latest action?", delegate: self, cancelButtonTitle:"No", otherButtonTitles:"Yes")
        alert.show()
    }

    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex > 0) {
            entryHandler.removeLastGulp()
            updateUI()
            wormhole!.passMessageObject("update", identifier: "mainUpdate")
        }
    }
}
