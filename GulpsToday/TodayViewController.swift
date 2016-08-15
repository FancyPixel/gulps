import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {

  @IBOutlet weak var bigGulpButton: UIButton!
  @IBOutlet weak var smallGulpButton: UIButton!
  @IBOutlet weak var smallConfirmButton: UIButton!
  @IBOutlet weak var bigConfirmButton: UIButton!
  @IBOutlet weak var summaryLabel: UILabel!
  @IBOutlet weak var smallLabel: UILabel!
  @IBOutlet weak var bigLabel: UILabel!
  var realmToken: NotificationToken?
  var gulpSize = Constants.Gulp.Small

  let userDefaults = NSUserDefaults.groupUserDefaults()
  let numberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    realmToken = EntryHandler.sharedHandler.realm.addNotificationBlock { note, realm in
      self.updateUI()
    }

    [bigConfirmButton, smallConfirmButton].forEach {$0.transform = CGAffineTransformMakeScale(0.001, 0.001)}
    title = "Gulps"
    preferredContentSize = CGSizeMake(0, 108)
    updateUI()
    updateLabels()
  }

  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    updateUI()
    updateLabels()
    completionHandler(NCUpdateResult.NewData)
  }

  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }

  func updateUI() {
    UIView.transitionWithView(self.summaryLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: {
      let quantity = self.numberFormatter.stringFromNumber(EntryHandler.sharedHandler.currentEntry().quantity)!
      let percentage = EntryHandler.sharedHandler.currentEntry().formattedPercentage()
      if let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Constants.General.UnitOfMeasure.key())) {
        let unitName = unit.nameForUnitOfMeasure()
        self.summaryLabel.text = String(format: NSLocalizedString("today extension format", comment: ""), quantity, unitName, percentage)
      }
      }, completion: nil)
  }

  func updateLabels() {
    var suffix = ""
    if let unit = Constants.UnitsOfMeasure(rawValue: userDefaults.integerForKey(Constants.General.UnitOfMeasure.key())) {
      suffix = unit.suffixForUnitOfMeasure()
    }

    smallLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Small.key()))!)\(suffix)"
    bigLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Big.key()))!)\(suffix)"
  }

  func confirmAction() {
    smallConfirmButton.backgroundColor = (gulpSize == .Small) ? .confirmColor() : .destructiveColor()
    bigConfirmButton.backgroundColor = (gulpSize == .Big) ? .confirmColor() : .destructiveColor()
    smallConfirmButton.setImage(UIImage(named: (gulpSize == .Small) ? "tiny-check" : "tiny-x"), forState: .Normal)
    bigConfirmButton.setImage(UIImage(named: (gulpSize == .Big) ? "tiny-check" : "tiny-x"), forState: .Normal)
    smallLabel.text = (gulpSize == .Small) ? NSLocalizedString("confirm", comment: "") : NSLocalizedString("never mind", comment: "")
    bigLabel.text = (gulpSize == .Small) ? NSLocalizedString("never mind", comment: "") : NSLocalizedString("confirm", comment: "")
    showConfirmButtons()
  }

  @IBAction func smallGulp(sender: UIButton) {
    gulpSize = Constants.Gulp.Small
    confirmAction()
  }

  @IBAction func bigGulp(sender: UIButton) {
    gulpSize = Constants.Gulp.Big
    confirmAction()
  }

  @IBAction func smallConfirmAction() {
    if (gulpSize == .Small) {
      addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Constants.Gulp.Small.key()))
    }
    hideConfirmButtons()
    updateLabels()
  }

  @IBAction func bigConfirmAction() {
    if (self.gulpSize == .Big) {
      addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Constants.Gulp.Big.key()))
    }
    updateLabels()
    hideConfirmButtons()
  }

  func addGulp(quantity: Double) {
    EntryHandler.sharedHandler.addGulp(quantity)
    summaryLabel.text = NSLocalizedString("way to go", comment: "")
    updateLabels()

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
      self.updateUI()
    }
  }
}
