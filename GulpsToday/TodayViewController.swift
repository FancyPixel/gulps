import UIKit
import NotificationCenter
import Realm

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var bigGulpButton: UIButton!
    @IBOutlet weak var smallGulpButton: UIButton!
    @IBOutlet weak var smallConfirmButton: UIButton!
    @IBOutlet weak var bigConfirmButton: UIButton!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet var entryHandler: EntryHandler!
    var realmToken: RLMNotificationToken?
    var gulpSize = Settings.Gulp.Small

    let userDefaults = NSUserDefaults.groupUserDefaults()
    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        EntryHandler.bootstrapRealm()

        realmToken = RLMRealm.defaultRealm().addNotificationBlock { note, realm in
            self.updateUI()
        }

        [bigConfirmButton, smallConfirmButton].map({$0.transform = CGAffineTransformMakeScale(0.001, 0.001)})
        self.title = "Gulps"
        self.preferredContentSize = CGSizeMake(0, 108)
        updateUI()
        updateLabels()
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        updateUI()
        updateLabels()
        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func updateUI() {
        UIView.transitionWithView(self.summaryLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
            let quantity = self.numberFormatter.stringFromNumber(self.entryHandler.currentEntry().quantity)!
            let percentage = self.entryHandler.currentEntry().formattedPercentage()
            if let unit = UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
                let unitName = unit.nameForUnitOfMeasure()
                self.summaryLabel.text = "\(quantity) \(unitName) drank today (\(percentage) of your goal)"
            }
            }, completion: nil)
    }

    func updateLabels() {
        var suffix = ""
        if let unit = UnitsOfMeasure(rawValue: userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
            suffix = unit.suffixForUnitOfMeasure()
        }

        smallLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Small.key()))!)\(suffix)"
        bigLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Big.key()))!)\(suffix)"
    }

    func confirmAction() {
        smallConfirmButton.backgroundColor = (gulpSize == .Small) ? .confirmColor() : .destructiveColor()
        bigConfirmButton.backgroundColor = (gulpSize == .Big) ? .confirmColor() : .destructiveColor()
        smallConfirmButton.setImage(UIImage(named: (gulpSize == .Small) ? "tiny-check" : "tiny-x"), forState: .Normal)
        bigConfirmButton.setImage(UIImage(named: (gulpSize == .Big) ? "tiny-check" : "tiny-x"), forState: .Normal)
        smallLabel.text = (gulpSize == .Small) ? "Confirm" : "Never mind"
        bigLabel.text = (gulpSize == .Small) ? "Never mind" : "Confirm"
        showConfirmButtons()
    }

    @IBAction func smallGulp(sender: UIButton) {
        self.gulpSize = Settings.Gulp.Small
        confirmAction()
    }

    @IBAction func bigGulp(sender: UIButton) {
        self.gulpSize = Settings.Gulp.Big
        confirmAction()
    }

    @IBAction func smallConfirmAction() {
        if (self.gulpSize == .Small) {
            addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Small.key()))
        }
        hideConfirmButtons()
        updateLabels()
    }

    @IBAction func bigConfirmAction() {
        if (self.gulpSize == .Big) {
            addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Big.key()))
        }
        updateLabels()
        hideConfirmButtons()
    }

    func addGulp(quantity: Double) {
        entryHandler.addGulp(quantity)
        summaryLabel.text = "Way to go!"
        updateLabels()

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.updateUI()
        }
    }
}
