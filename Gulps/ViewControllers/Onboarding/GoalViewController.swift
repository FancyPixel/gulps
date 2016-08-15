import UIKit

class GoalViewController: OnboardingViewController, UITextFieldDelegate {

    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalSuffixLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var goalBackgroundView: UIView!
    let userDefaults = NSUserDefaults.groupUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.goalTextField.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GoalViewController.dismissAndSave))
        self.goalBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.goalTextField, action: #selector(UIResponder.becomeFirstResponder)))
    }

    func dismissAndSave() {
        guard let text = goalTextField.text else {
            return
        }

        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle

        self.goalTextField.resignFirstResponder()

        var goal = 0.0
        if let number = numberFormatter.numberFromString(text) {
            goal = number as Double
        }

        self.userDefaults.setDouble(goal, forKey: Constants.Gulp.Goal.key())
        self.userDefaults.synchronize()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        dismissAndSave()

        return true
    }

    override func updateUI() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        self.goalTextField.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Constants.Gulp.Goal.key()))
        let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Constants.General.UnitOfMeasure.key()))

        if let unit = unit {
            self.goalSuffixLabel.text = unit.suffixForUnitOfMeasure()
        }
    }
}
