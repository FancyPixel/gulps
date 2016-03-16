import UIKit
import pop

class MeasureViewController: OnboardingViewController {

    @IBOutlet weak var litersCheck: UIImageView!
    @IBOutlet weak var ouncesCheck: UIImageView!
    let userDefaults = NSUserDefaults.groupUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = [litersCheck, ouncesCheck].map({$0.transform = CGAffineTransformMakeScale(0.001, 0.001)})
    }

    override func goNextScreen(gesture: UIGestureRecognizer) {
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewControllerWithIdentifier("GulpsViewController"))!, animated: true)
    }
    
    override func goPrevScreen(gesture: UIGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func updateUI() {
        let unit = Constants.UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Constants.General.UnitOfMeasure.key()))

        let scaleUp = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleUp.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleUp.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleUp.removedOnCompletion = true

        let scaleDown = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDown.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDown.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDown.removedOnCompletion = true

        if (unit == Constants.UnitsOfMeasure.Liters) {
            self.litersCheck.pop_addAnimation(scaleUp, forKey: "scaleUp")
            self.ouncesCheck.pop_addAnimation(scaleDown, forKey: "scaleDown")
            Settings.registerDefaultsForLiter()
        } else {
            self.litersCheck.pop_addAnimation(scaleDown, forKey: "scaleDown")
            self.ouncesCheck.pop_addAnimation(scaleUp, forKey: "scaleUp")
            Settings.registerDefaultsForOunces()
        }
    }

    @IBAction func ouncesButtonAction() {
        self.userDefaults.setInteger(Constants.UnitsOfMeasure.Ounces.rawValue, forKey: Constants.General.UnitOfMeasure.key())
        self.userDefaults.synchronize()
        updateUI()
    }

    @IBAction func litersButtonAction() {
        self.userDefaults.setInteger(Constants.UnitsOfMeasure.Liters.rawValue, forKey: Constants.General.UnitOfMeasure.key())
        self.userDefaults.synchronize()
        updateUI()
    }
}
