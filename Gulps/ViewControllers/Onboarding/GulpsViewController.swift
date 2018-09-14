import UIKit
import pop

// TO-DO: Fix timing of medium gulp onboarding

class GulpsViewController: OnboardingViewController, UITextFieldDelegate {

  @IBOutlet weak var smallGulpText: UITextField!
  @IBOutlet weak var bigGulpText: UITextField!
  @IBOutlet weak var smallSuffixLabel: UILabel!
  @IBOutlet weak var bigSuffixLabel: UILabel!
  @IBOutlet weak var mediumSuffixLabel: UILabel!
  @IBOutlet weak var mediumGulpText: UITextField!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var smallBackgroundView: UIView!
  @IBOutlet weak var bigBackgroundView: UIView!
  @IBOutlet weak var mediumBackgroundView: UIView!
    
    
  let userDefaults = UserDefaults.groupUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.smallGulpText.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GulpsViewController.dismissAndSave))
    
    self.mediumGulpText.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GulpsViewController.dismissAndSave))
    
    self.bigGulpText.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GulpsViewController.dismissAndSave))

    self.smallBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.smallGulpText, action: #selector(UIResponder.becomeFirstResponder)))
    self.mediumBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.mediumGulpText, action: #selector(UIResponder.becomeFirstResponder)))
    self.bigBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.bigGulpText, action: #selector(UIResponder.becomeFirstResponder)))

    NotificationCenter.default.addObserver(self, selector: #selector(GulpsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(GulpsViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  @objc func dismissAndSave() {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal

    _ = [self.smallGulpText, self.mediumGulpText, self.bigGulpText].map({$0.resignFirstResponder()})

    var small = 0.0
    var medium = 0.0
    var big = 0.0
    if let number = numberFormatter.number(from: self.smallGulpText.text ?? "0") {
      small = number.doubleValue
    }
    
    if let number = numberFormatter.number(from: self.mediumGulpText.text ?? "0") {
      medium = number.doubleValue
    }

    if let number = numberFormatter.number(from: self.bigGulpText.text ?? "0") {
      big = number.doubleValue
    }

    self.userDefaults.set(small, forKey: Constants.Gulp.small.key())
    self.userDefaults.set(medium, forKey: Constants.Gulp.medium.key())
    self.userDefaults.set(big, forKey: Constants.Gulp.big.key())
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
    self.smallGulpText.text = numberFormatter.string(for: self.userDefaults.double(forKey: Constants.Gulp.small.key()))
    self.mediumGulpText.text = numberFormatter.string(for: self.userDefaults.double(forKey: Constants.Gulp.medium.key()))
    self.bigGulpText.text = numberFormatter.string(for: self.userDefaults.double(forKey: Constants.Gulp.big.key()))
    let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integer(forKey: Constants.General.unitOfMeasure.key()))

    if let unit = unit {
      self.smallSuffixLabel.text = unit.suffixForUnitOfMeasure()
      self.mediumSuffixLabel.text = unit.suffixForUnitOfMeasure()
      self.bigSuffixLabel.text = unit.suffixForUnitOfMeasure()
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    _ = [self.smallGulpText, self.mediumGulpText, self.bigGulpText].map({$0.resignFirstResponder()})
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    scrollViewTo(-(self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height), from: 0)
  }

  @objc func keyboardWillHide(_ notification: Notification) {
    scrollViewTo(0, from: -(self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height))
  }

  func scrollViewTo(_ offset: CGFloat, from: CGFloat) {
    let move = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
    move?.fromValue = from
    move?.toValue = offset
    move?.removedOnCompletion = true
    self.view.layer.pop_add(move, forKey: "move")
  }
}
