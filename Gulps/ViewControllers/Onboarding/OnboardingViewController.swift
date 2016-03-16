import UIKit
import AMWaveTransition

class OnboardingViewController: AMWaveViewController, UIGestureRecognizerDelegate {

    @IBOutlet var viewArray: [UIView]!
    
    //var arrVC = ["OnboardingViewController", "MeasureViewController", "GulpsViewController", "GoalViewController", "NotificationViewController"] // this is the stack of viewControllers used on Onboarding.storyboard

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.view.backgroundColor = UIColor.mainColor()
        self.view.backgroundColor = UIColor.clearColor()
        let lsg = UISwipeGestureRecognizer(target: self, action:"goNextScreen:")
        lsg.direction = .Left
        lsg.delegate = self
        self.view.addGestureRecognizer(lsg)
        let rsg = UISwipeGestureRecognizer(target: self, action:"goPrevScreen:")
        rsg.direction = .Right
        rsg.delegate = self
        self.view.addGestureRecognizer(rsg)
        updateUI()
    }
    
    func goNextScreen(gesture:UIGestureRecognizer)
    {
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewControllerWithIdentifier("MeasureViewController"))!, animated: true)
    }
    
    func goPrevScreen(gesture:UIGestureRecognizer)
    {
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
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
