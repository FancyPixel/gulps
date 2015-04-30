import UIKit
import pop

class MeasureViewController: OnboardingViewController {

    @IBOutlet weak var litersCheck: UIImageView!
    @IBOutlet weak var ouncesCheck: UIImageView!
    let userDefaults = NSUserDefaults.groupUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        [litersCheck, ouncesCheck].map({$0.transform = CGAffineTransformMakeScale(0.001, 0.001)})
    }

    override func updateUI() {
        let unit = UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Settings.General.UnitOfMeasure.key()))

        let scaleUp = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleUp.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleUp.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleUp.removedOnCompletion = true

        let scaleDown = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDown.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDown.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDown.removedOnCompletion = true

        if (unit == UnitsOfMeasure.Liters) {
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
        self.userDefaults.setInteger(UnitsOfMeasure.Ounces.rawValue, forKey: Settings.General.UnitOfMeasure.key())
        self.userDefaults.synchronize()
        updateUI()
    }

    @IBAction func litersButtonAction() {
        self.userDefaults.setInteger(UnitsOfMeasure.Liters.rawValue, forKey: Settings.General.UnitOfMeasure.key())
        self.userDefaults.synchronize()
        updateUI()
    }
}
