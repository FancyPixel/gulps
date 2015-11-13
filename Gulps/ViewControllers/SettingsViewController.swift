import UIKit
import AHKActionSheet
import WatchConnectivity

class SettingsViewController: UITableViewController, UIAlertViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var unitOfMesureLabel: UILabel!
    @IBOutlet weak var smallPortionText: UITextField!
    @IBOutlet weak var largePortionText: UITextField!
    @IBOutlet weak var dailyGoalText: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var healthSwitch: UISwitch!
    @IBOutlet weak var notificationFromLabel: UILabel!
    @IBOutlet weak var notificationToLabel: UILabel!
    @IBOutlet weak var notificationIntervalLabel: UILabel!
    @IBOutlet var uomLabels: [UILabel]!

    let userDefaults = NSUserDefaults.groupUserDefaults()

    let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("settings title", comment: "")
        for element in [smallPortionText, largePortionText, dailyGoalText] {
            element.inputAccessoryView = Globals.numericToolbar(element,
                selector: Selector("resignFirstResponder"),
                barColor: .mainColor(),
                textColor: .whiteColor())
        }

        if (WCSession.isSupported()) {
            WCSession.defaultSession().activateSession()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        var suffix = ""
        if let unit = Constants.UnitsOfMeasure(rawValue: userDefaults.integerForKey(Constants.General.UnitOfMeasure.key())) {
            unitOfMesureLabel.text = unit.nameForUnitOfMeasure()
            suffix = unit.suffixForUnitOfMeasure()
        }

        _ = uomLabels.map({$0.text = suffix})
        largePortionText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Big.key()))
        smallPortionText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Small.key()))
        dailyGoalText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Goal.key()))

        healthSwitch.on = userDefaults.boolForKey(Constants.Health.On.key())

        notificationSwitch.on = userDefaults.boolForKey(Constants.Notification.On.key())
        notificationFromLabel.text = "\(userDefaults.integerForKey(Constants.Notification.From.key())):00"
        notificationToLabel.text = "\(userDefaults.integerForKey(Constants.Notification.To.key())):00"
        notificationIntervalLabel.text = "\(userDefaults.integerForKey(Constants.Notification.Interval.key())) " +  NSLocalizedString("hours", comment: "")
    }

    func updateNotificationPreferences() {
        if (notificationSwitch.on) {
            NotificationHelper.unscheduleNotifications()
            NotificationHelper.askPermission()
        } else {
            NotificationHelper.unscheduleNotifications()
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var actionSheet: AHKActionSheet?
        if (indexPath.section == 0 && indexPath.row == 0) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("unit of measure title", comment: ""))
            actionSheet?.addButtonWithTitle(Constants.UnitsOfMeasure.Liters.nameForUnitOfMeasure(), type: .Default) { _ in
                self.userDefaults.setInteger(Constants.UnitsOfMeasure.Liters.rawValue, forKey: Constants.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            }
            actionSheet?.addButtonWithTitle(Constants.UnitsOfMeasure.Ounces.nameForUnitOfMeasure(), type: .Default) { _ in
                self.userDefaults.setInteger(Constants.UnitsOfMeasure.Ounces.rawValue, forKey: Constants.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            }
        }
        if (indexPath.section == 2 && indexPath.row == 1) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("from:", comment: ""))
            for index in 5...22 {
                actionSheet?.addButtonWithTitle("\(index):00", type: .Default) { _ in
                    self.updateNotificationSetting(Constants.Notification.From.key(), value: index)
                }
            }
        }
        if (indexPath.section == 2 && indexPath.row == 2) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("to:", comment: ""))
            let upper = self.userDefaults.integerForKey(Constants.Notification.From.key()) + 1
            for index in upper...24 {
                actionSheet?.addButtonWithTitle("\(index):00", type: .Default) { _ in
                    self.updateNotificationSetting(Constants.Notification.To.key(), value: index)
                }
            }
        }
        if (indexPath.section == 2 && indexPath.row == 3) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("every:", comment: ""))
            for index in 1...8 {
                let hour = index > 1 ? NSLocalizedString("hours", comment: "") : NSLocalizedString("hour", comment: "")
                actionSheet?.addButtonWithTitle("\(index) \(hour)", type: .Default) { _ in
                    self.updateNotificationSetting(Constants.Notification.Interval.key(), value: index)
                }
            }
        }
        if let actionSheet = actionSheet {
            actionSheet.show()
        }
    }

    func updateNotificationSetting(key: String, value: Int) {
        userDefaults.setInteger(value, forKey: key)
        userDefaults.synchronize()
        updateUI()
        updateNotificationPreferences()
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    @IBAction func healthAction(sender: UISwitch) {
        userDefaults.setBool(sender.on, forKey: Constants.Health.On.key())
        userDefaults.synchronize()
        self.tableView.reloadData()
        if sender.on {
            HealthKitHelper.sharedHelper.askPermission()
        }
    }

    @IBAction func reminderAction(sender: UISwitch) {
        userDefaults.setBool(sender.on, forKey: Constants.Notification.On.key())
        userDefaults.synchronize()
        self.tableView.reloadData()
        updateNotificationPreferences()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 3
        } else if (section == 2) {
            if NSUserDefaults.groupUserDefaults().boolForKey(Constants.Notification.On.key()) {
                return 4
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == smallPortionText) {
            storeText(smallPortionText, toKey: Constants.Gulp.Small.key())
        }
        if (textField == largePortionText) {
            storeText(largePortionText, toKey: Constants.Gulp.Big.key())
        }
        if (textField == dailyGoalText) {
            storeText(dailyGoalText, toKey: Constants.Gulp.Goal.key())
        }
    }

    func storeText(textField: UITextField, toKey key: String) {
        guard let text = textField.text else {
            return
        }
        let number = numberFormatter.numberFromString(text) as? Double
        userDefaults.setDouble(number ?? 0.0, forKey: key)
        userDefaults.synchronize()

        // Update the settings on the watch
        WatchConnectivityHelper().sendWatchData()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
