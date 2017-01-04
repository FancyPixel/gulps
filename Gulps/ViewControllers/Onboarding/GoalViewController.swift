import UIKit

class GoalViewController: OnboardingViewController, UITextFieldDelegate {

  @IBOutlet weak var goalTextField: UITextField!
  @IBOutlet weak var goalSuffixLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var goalBackgroundView: UIView!
  let userDefaults = UserDefaults.groupUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.goalTextField.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GoalViewController.dismissAndSave))
    self.goalBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.goalTextField, action: #selector(UIResponder.becomeFirstResponder)))
  }

  func dismissAndSave() {
    guard let text = goalTextField.text else {
      return
    }

    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal

    self.goalTextField.resignFirstResponder()

    var goal = 0.0
    if let number = numberFormatter.number(from: text) {
      goal = number as Double
    }

    self.userDefaults.set(goal, forKey: Constants.Gulp.goal.key())
    self.userDefaults.synchronize()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    dismissAndSave()

    return true
  }

  override func updateUI() {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    self.goalTextField.text = numberFormatter.string(for: self.userDefaults.double(forKey: Constants.Gulp.goal.key()))
    let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integer(forKey: Constants.General.unitOfMeasure.key()))

    if let unit = unit {
      self.goalSuffixLabel.text = unit.suffixForUnitOfMeasure()
    }
  }
}
