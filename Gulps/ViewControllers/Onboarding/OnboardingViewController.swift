import UIKit
import AMWaveTransition

class OnboardingViewController: AMWaveViewController {

  @IBOutlet var viewArray: [UIView]!

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.view.backgroundColor = .palette_main
    view.backgroundColor = .clear

    updateUI()
  }

  override var prefersStatusBarHidden : Bool {
    return true
  }

  override func visibleCells() -> [Any]! {
    return self.viewArray
  }

  func updateUI() {

  }

  @IBAction func backAction() {
    _ = navigationController?.popViewController(animated: true)
  }

  func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
  }
}
