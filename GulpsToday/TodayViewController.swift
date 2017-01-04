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
  var gulpSize = Constants.Gulp.small

  let userDefaults = UserDefaults.groupUserDefaults()
  let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    realmToken = EntryHandler.sharedHandler.realm.addNotificationBlock { note, realm in
      self.updateUI()
    }

    [bigConfirmButton, smallConfirmButton].forEach {$0.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)}
    title = "Gulps"
    preferredContentSize = CGSize(width: 0, height: 108)
    updateUI()
    updateLabels()
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    updateUI()
    updateLabels()
    completionHandler(NCUpdateResult.newData)
  }

  func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }

  func updateUI() {
    UIView.transition(with: self.summaryLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
      let quantity = self.numberFormatter.string(for: EntryHandler.sharedHandler.currentEntry().quantity)!
      let percentage = EntryHandler.sharedHandler.currentEntry().formattedPercentage()
      if let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integer(forKey: Constants.General.unitOfMeasure.key())) {
        let unitName = unit.nameForUnitOfMeasure()
        self.summaryLabel.text = String(format: NSLocalizedString("today extension format", comment: ""), quantity, unitName, percentage)
      }
      }, completion: nil)
  }

  func updateLabels() {
    var suffix = ""
    if let unit = Constants.UnitsOfMeasure(rawValue: userDefaults.integer(forKey: Constants.General.unitOfMeasure.key())) {
      suffix = unit.suffixForUnitOfMeasure()
    }

    smallLabel.text = "\(numberFormatter.string(for: userDefaults.double(forKey: Constants.Gulp.small.key()))!)\(suffix)"
    bigLabel.text = "\(numberFormatter.string(for: userDefaults.double(forKey: Constants.Gulp.big.key()))!)\(suffix)"
  }

  func confirmAction() {
    smallConfirmButton.backgroundColor = (gulpSize == .small) ? .palette_confirm : .palette_destructive
    bigConfirmButton.backgroundColor = (gulpSize == .big) ? .palette_confirm : .palette_destructive
    smallConfirmButton.setImage(UIImage(named: (gulpSize == .small) ? "tiny-check" : "tiny-x"), for: UIControlState())
    bigConfirmButton.setImage(UIImage(named: (gulpSize == .big) ? "tiny-check" : "tiny-x"), for: UIControlState())
    smallLabel.text = (gulpSize == .small) ? NSLocalizedString("confirm", comment: "") : NSLocalizedString("never mind", comment: "")
    bigLabel.text = (gulpSize == .small) ? NSLocalizedString("never mind", comment: "") : NSLocalizedString("confirm", comment: "")
    showConfirmButtons()
  }

  @IBAction func smallGulp(_ sender: UIButton) {
    gulpSize = Constants.Gulp.small
    confirmAction()
  }

  @IBAction func bigGulp(_ sender: UIButton) {
    gulpSize = Constants.Gulp.big
    confirmAction()
  }

  @IBAction func smallConfirmAction() {
    if (gulpSize == .small) {
      addGulp(UserDefaults.groupUserDefaults().double(forKey: Constants.Gulp.small.key()))
    }
    hideConfirmButtons()
    updateLabels()
  }

  @IBAction func bigConfirmAction() {
    if (self.gulpSize == .big) {
      addGulp(UserDefaults.groupUserDefaults().double(forKey: Constants.Gulp.big.key()))
    }
    updateLabels()
    hideConfirmButtons()
  }

  func addGulp(_ quantity: Double) {
    EntryHandler.sharedHandler.addGulp(quantity)
    summaryLabel.text = NSLocalizedString("way to go", comment: "")
    updateLabels()

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
      self.updateUI()
    }
  }
}
