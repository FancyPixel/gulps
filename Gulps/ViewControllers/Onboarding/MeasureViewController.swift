import UIKit
import pop

class MeasureViewController: OnboardingViewController {

  @IBOutlet weak var litersCheck: UIImageView!
  @IBOutlet weak var ouncesCheck: UIImageView!
  let userDefaults = UserDefaults.groupUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()
    [litersCheck, ouncesCheck].forEach {$0.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)}
  }

  override func updateUI() {
    let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integer(forKey: Constants.General.unitOfMeasure.key()))

    let scaleUp = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
    scaleUp?.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
    scaleUp?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scaleUp?.removedOnCompletion = true

    let scaleDown = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
    scaleDown?.fromValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scaleDown?.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
    scaleDown?.removedOnCompletion = true

    if (unit == Constants.UnitsOfMeasure.liters) {
      self.litersCheck.pop_add(scaleUp, forKey: "scaleUp")
      self.ouncesCheck.pop_add(scaleDown, forKey: "scaleDown")
      Settings.registerDefaultsForLiter()
    } else {
      self.litersCheck.pop_add(scaleDown, forKey: "scaleDown")
      self.ouncesCheck.pop_add(scaleUp, forKey: "scaleUp")
      Settings.registerDefaultsForOunces()
    }
  }

  @IBAction func ouncesButtonAction() {
    self.userDefaults.set(Constants.UnitsOfMeasure.ounces.rawValue, forKey: Constants.General.unitOfMeasure.key())
    self.userDefaults.synchronize()
    updateUI()
  }

  @IBAction func litersButtonAction() {
    self.userDefaults.set(Constants.UnitsOfMeasure.liters.rawValue, forKey: Constants.General.unitOfMeasure.key())
    self.userDefaults.synchronize()
    updateUI()
  }
}
