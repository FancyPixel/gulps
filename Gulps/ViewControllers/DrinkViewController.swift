import UIKit
import BAFluidView
import UICountingLabel
import Realm
import BubbleTransition
import CoreMotion

public class DrinkViewController: UIViewController, UIAlertViewDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet public weak var percentageLabel: UICountingLabel!
    @IBOutlet public weak var addButton: UIButton!
    @IBOutlet public weak var smallButton: UIButton!
    @IBOutlet public weak var customButton: UIButton!
    @IBOutlet public weak var largeButton: UIButton!
    @IBOutlet public weak var minusButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var meterContainerView: UIView!
    @IBOutlet weak var maskImage: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!

    public var userDefaults = NSUserDefaults.groupUserDefaults()
    public var progressMeter: BAFluidView?
    var realmNotification: RLMNotificationToken?
    var expanded = false
    let transition = BubbleTransition()
    let manager = CMMotionManager()

    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("drink title", comment: "")

        initAnimation()

        percentageLabel.animationDuration = 1.5
        percentageLabel.format = "%d%%";

        manager.accelerometerUpdateInterval = 0.01
        manager.deviceMotionUpdateInterval = 0.01;
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (motion, error) in
            if let motion = motion {
                let roation = atan2(motion.gravity.x, motion.gravity.y) - M_PI
                self.progressMeter?.transform = CGAffineTransformMakeRotation(CGFloat(roation))
            }
        }

        realmNotification = EntryHandler.sharedHandler.realm.addNotificationBlock { note, realm in
            self.updateUI()
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    public override func prefersStatusBarHidden() -> Bool {
        return false
    }

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if NSUserDefaults.groupUserDefaults().boolForKey(Constants.CustomGulp.On.key()) {
            customButton.userInteractionEnabled = true
            customButton.hidden = false
        } else {
            customButton.userInteractionEnabled = false
            customButton.hidden = true
        }

        view.layoutIfNeeded()

        // Init the progress meter programamtically to avoid an animation glitch
        if progressMeter == nil {
            let width = meterContainerView.frame.size.width
            progressMeter = BAFluidView(frame: CGRect(x: 0, y: 0, width: width, height: width), maxAmplitude: 40, minAmplitude: 8, amplitudeIncrement: 1)
            progressMeter!.backgroundColor = .clearColor()
            progressMeter!.fillColor = .mainColor()
            progressMeter!.fillAutoReverse = false
            progressMeter!.fillDuration = 1.5
            progressMeter!.fillRepeatCount = 0;
            meterContainerView.insertSubview(progressMeter!, belowSubview: maskImage)

            updateUI()
        }

        if !userDefaults.boolForKey("FEEDBACK") {
            if EntryHandler.sharedHandler.overallQuantity() > 10 {
                animateStarButton()
            }
        }
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        Globals.showPopTipOnceForKey("HEALTH_HINT", userDefaults: userDefaults,
            popTipText: NSLocalizedString("health.poptip", comment: ""),
            inView: view,
            fromFrame: CGRect(x: view.frame.width - 60, y: view.frame.height, width: 1, height: 1), direction: .Up, color: .destructiveColor())
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (expanded) {
            contractAddButton()
        }
    }

    // MARK: - UI update

    func updateCurrentEntry(delta: Double) {
        EntryHandler.sharedHandler.addGulp(delta)
    }

    func updateUI() {
        let percentage = EntryHandler.sharedHandler.currentPercentage()
        percentageLabel.countFromCurrentValueTo(Float(round(percentage)))
        let fillTo = CGFloat(percentage / 100.0)
        progressMeter?.fillTo(fillTo > 1 ? 1 : fillTo)
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "feedback" {
            let controller = segue.destinationViewController
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
            userDefaults.setBool(true, forKey: "FEEDBACK")
            userDefaults.synchronize()
        }
        
        if let customViewController = segue.destinationViewController as? CustomViewController {
            customViewController.gulpSize = {[weak self]
                (value) in
                if let weakSelf = self {
                    weakSelf.addCustomGulp(value)
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func addButtonAction(sender: UIButton) {
        if (expanded) {
            contractAddButton()
        } else {
            expandAddButton()
        }
    }

    @IBAction public func selectionButtonAction(sender: UIButton) {
        contractAddButton()
        Globals.showPopTipOnceForKey("UNDO_HINT", userDefaults: userDefaults,
            popTipText: NSLocalizedString("undo poptip", comment: ""),
            inView: view,
            fromFrame: minusButton.frame)
        
        let portion = smallButton == sender ? Constants.Gulp.Small.key() : Constants.Gulp.Big.key()
        addGulp(portion)
    }

    @IBAction func removeGulpAction() {
        let controller = UIAlertController(title: NSLocalizedString("undo title", comment: ""), message: NSLocalizedString("undo message", comment: ""), preferredStyle: .Alert)
        let no = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Default) { _ in }
        let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Cancel) { _ in
            EntryHandler.sharedHandler.removeLastGulp()
        }
        _ = [yes, no].map { controller.addAction($0) }
        self.presentViewController(controller, animated: true) {}
    }
    
    private func addGulp(portion: String) {
        updateCurrentEntry(userDefaults.doubleForKey(portion))
    }
    
    private func addCustomGulp(value: String) {
        // TODO: Remove duplicated code
        contractAddButton()
        Globals.showPopTipOnceForKey("UNDO_HINT", userDefaults: userDefaults,
            popTipText: NSLocalizedString("undo poptip", comment: ""),
            inView: view,
            fromFrame: minusButton.frame)
        
        
        addGulp(Constants.Gulp.Custom.key())
    }

    // MARK: - UIViewControllerTransitioningDelegate

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        let center = CGPoint(x: starButton.center.x, y: starButton.center.y + 64)
        transition.startingPoint = center
        transition.bubbleColor = UIColor(red: 245.0/255.0, green: 192.0/255.0, blue: 24.0/255.0, alpha: 1)
        return transition
    }

    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = CGPoint(x: starButton.center.x, y: starButton.center.y + 64)
        transition.bubbleColor = UIColor(red: 245.0/255.0, green: 192.0/255.0, blue: 24.0/255.0, alpha: 1)
        starButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
        return transition
    }

    // MARK: - Tear down

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
