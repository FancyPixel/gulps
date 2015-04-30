import UIKit
import AMWaveTransition

class OnboardingViewController: AMWaveViewController {

    @IBOutlet var viewArray: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.view.backgroundColor = UIColor.mainColor()
        self.view.backgroundColor = UIColor.clearColor()
        
        updateUI()
    }

    override func visibleCells() -> [AnyObject]! {
        return self.viewArray
    }

    func updateUI() {

    }

    @IBAction func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
