import UIKit
import AHKActionSheet

class NotificationViewController: OnboardingViewController, UIActionSheetDelegate {

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    let userDefaults = NSUserDefaults.groupUserDefaults()

    lazy var fromActionSheet: AHKActionSheet = {
        var actionSheet = AHKActionSheet(title: "From:")
        for index in 5...22 {
            actionSheet.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(index, forKey: Settings.Notification.From.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
        }
        return actionSheet
    }()

    lazy var intervalActionSheet: AHKActionSheet = {
        var actionSheet = AHKActionSheet(title: "Every:")
        for index in 1...8 {
            let hour = index > 1 ? "hours" : "hour"
            actionSheet.addButtonWithTitle("\(index) \(hour)", type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(index, forKey: Settings.Notification.Interval.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
        }
        return actionSheet
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func updateUI() {
        self.fromLabel.text = "\(self.userDefaults.integerForKey(Settings.Notification.From.key())):00"
        self.toLabel.text = "\(self.userDefaults.integerForKey(Settings.Notification.To.key())):00"
        let interval = self.userDefaults.integerForKey(Settings.Notification.Interval.key())
        let hour = interval > 1 ? "hours" : "hour"
        self.intervalLabel.text = "\(interval) \(hour)"
        self.notificationSwitch.on = self.userDefaults.boolForKey(Settings.Notification.On.key())
    }

    @IBAction func openFromSelection(sender: UIButton) {
        self.fromActionSheet.show()
    }

    @IBAction func openIntervalSelection(sender: UIButton) {
        self.intervalActionSheet.show()
    }

    @IBAction func openToSelection(sender: UIButton) {
        let toActionSheet = AHKActionSheet(title: "To:")
        let upper = self.userDefaults.integerForKey(Settings.Notification.From.key()) + 1
        for index in upper...24 {
            toActionSheet!.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(index, forKey: Settings.Notification.To.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
        }
        toActionSheet.show()
    }

    @IBAction func enableNotifications(sender: UISwitch) {
        self.userDefaults.setBool(sender.on, forKey: Settings.Notification.On.key())
        self.userDefaults.synchronize()
    }

    @IBAction func doneAction() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        userDefaults.setBool(true, forKey: Settings.General.OnboardingShown.key())
        NotificationHelper.unscheduleNotifications()
        NotificationHelper.askPermission()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.loadMainInterface()
    }
}
