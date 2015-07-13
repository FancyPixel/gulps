import UIKit
import BAFluidView
import UICountingLabel
import Realm
import BubbleTransition

public class DrinkViewController: UIViewController, UIAlertViewDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet public weak var progressMeterBackground: UIImageView!
    @IBOutlet public weak var percentageLabel: UICountingLabel!
    @IBOutlet public weak var addButton: UIButton!
    @IBOutlet public weak var smallButton: UIButton!
    @IBOutlet public weak var largeButton: UIButton!
    @IBOutlet public weak var minusButton: UIButton!
    @IBOutlet public var entryHandler: EntryHandler!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet public weak var progressMeter: BAFluidView!
    public var userDefaults = NSUserDefaults.groupUserDefaults()
    let mask = CALayer()
    var expanded = false
    var realmToken: RLMNotificationToken?
    let transition = BubbleTransition()

    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Drink!"

        initAnimation()

        percentageLabel.animationDuration = 1.5
        percentageLabel.format = "%d%%";

        realmToken = RLMRealm.defaultRealm().addNotificationBlock { note, realm in
            self.updateUI()
        }

        progressMeterBackground.image = UIImage(named: "drop-bg")
        progressMeterBackground.contentMode = .Center
        progressMeterBackground.backgroundColor = .clearColor()

        progressMeter.backgroundColor = .clearColor()
        progressMeter.fillColor = .mainColor()

        progressMeter.fillAutoReverse = false
        progressMeter.fillRepeatCount = 0;
        progressMeter.amplitudeIncrement = 1

        if let image = UIImage(named: "drop") {
            mask.contents = image.CGImage
            progressMeter.layer.mask = mask
            mask.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(progressMeter, selector: "stopAnimation", name: UIApplicationWillResignActiveNotification, object: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mask.frame = CGRect(x: (progressMeter.frame.size.width - mask.frame.size.width) / 2, y: (progressMeter.frame.size.height - mask.frame.size.height) / 2, width: mask.frame.size.width, height: mask.frame.size.height)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
//        animateStarButton()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        progressMeter.stopAnimation()
    }

    // MARK: - UI update

    func updateCurrentEntry(delta: Double) {
        entryHandler.addGulp(delta)
    }

    func updateUI() {
        let percentage = self.entryHandler.currentEntry().percentage
        percentageLabel.countFromCurrentValueTo(Float(round(percentage)))
        progressMeter.fillTo(CGFloat(percentage / 100.0))
        progressMeter.startAnimation()
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
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
            popTipText: "Tap here to undo your latest action",
            inView: view,
            fromFrame: minusButton.frame)
        let portion = smallButton == sender ? Settings.Gulp.Small.key() : Settings.Gulp.Big.key()
        updateCurrentEntry(userDefaults.doubleForKey(portion))
    }

    @IBAction func removeGulpAction() {
        let controller = UIAlertController(title: "Undo", message: "Undo latest action?", preferredStyle: .Alert)
        let no = UIAlertAction(title: "No", style: .Default) { _ in }
        let yes = UIAlertAction(title: "Yes", style: .Cancel) { _ in
            self.entryHandler.removeLastGulp()
        }
        [yes, no].map { controller.addAction($0) }
        self.presentViewController(controller, animated: true) {}
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
        transition.startingPoint = starButton.center
        transition.bubbleColor = UIColor(red: 245.0/255.0, green: 192.0/255.0, blue: 24.0/255.0, alpha: 1)
        return transition
    }

    // MARK: - Tear down

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
