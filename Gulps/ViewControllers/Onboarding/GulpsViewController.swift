import UIKit
import pop

class GulpsViewController: OnboardingViewController, UITextFieldDelegate {

  @IBOutlet weak var smallGulpText: UITextField!
  @IBOutlet weak var bigGulpText: UITextField!
  @IBOutlet weak var smallSuffixLabel: UILabel!
  @IBOutlet weak var bigSuffixLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var smallBackgroundView: UIView!
  @IBOutlet weak var bigBackgroundView: UIView!

  let userDefaults = NSUserDefaults.groupUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.smallGulpText.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GulpsViewController.dismissAndSave))
    self.bigGulpText.inputAccessoryView = Globals.numericToolbar(self, selector: #selector(GulpsViewController.dismissAndSave))

    self.smallBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.smallGulpText, action: #selector(UIResponder.becomeFirstResponder)))
    self.bigBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self.bigGulpText, action: #selector(UIResponder.becomeFirstResponder)))

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GulpsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GulpsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }

  func dismissAndSave() {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.numberStyle = .DecimalStyle

    _ = [self.smallGulpText, self.bigGulpText].map({$0.resignFirstResponder()})

    var small = 0.0
    var big = 0.0
    if let number = numberFormatter.numberFromString(self.smallGulpText.text ?? "0") {
      small = number as Double
    }

    if let number = numberFormatter.numberFromString(self.bigGulpText.text ?? "0") {
      big = number as Double
    }

    self.userDefaults.setDouble(small, forKey: Constants.Gulp.Small.key())
    self.userDefaults.setDouble(big, forKey: Constants.Gulp.Big.key())
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
    self.smallGulpText.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Constants.Gulp.Small.key()))
    self.bigGulpText.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Constants.Gulp.Big.key()))
    let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Constants.General.UnitOfMeasure.key()))

    if let unit = unit {
      self.smallSuffixLabel.text = unit.suffixForUnitOfMeasure()
      self.bigSuffixLabel.text = unit.suffixForUnitOfMeasure()
    }
  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    _ = [self.smallGulpText, self.bigGulpText].map({$0.resignFirstResponder()})
  }

  func keyboardWillShow(notification: NSNotification) {
    scrollViewTo(-(self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height), from: 0)
  }

  func keyboardWillHide(notification: NSNotification) {
    scrollViewTo(0, from: -(self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height))
  }

  func scrollViewTo(offset: CGFloat, from: CGFloat) {
    let move = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
    move.fromValue = from
    move.toValue = offset
    move.removedOnCompletion = true
    self.view.layer.pop_addAnimation(move, forKey: "move")
  }
}
