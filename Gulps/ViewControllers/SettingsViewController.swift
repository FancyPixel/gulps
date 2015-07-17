import UIKit
import AHKActionSheet

class SettingsViewController: UITableViewController, UIAlertViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var unitOfMesureLabel: UILabel!
    @IBOutlet weak var smallPortionText: UITextField!
    @IBOutlet weak var largePortionText: UITextField!
    @IBOutlet weak var dailyGoalText: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
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
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        var suffix = ""
        if let unit = UnitsOfMeasure(rawValue: userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
            unitOfMesureLabel.text = unit.nameForUnitOfMeasure()
            suffix = unit.suffixForUnitOfMeasure()
        }

        uomLabels.map({$0.text = suffix})
        largePortionText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Big.key()))
        smallPortionText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Small.key()))
        dailyGoalText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Goal.key()))

        notificationSwitch.on = userDefaults.boolForKey(Settings.Notification.On.key())
        notificationFromLabel.text = "\(userDefaults.integerForKey(Settings.Notification.From.key())):00"
        notificationToLabel.text = "\(userDefaults.integerForKey(Settings.Notification.To.key())):00"
        notificationIntervalLabel.text = "\(userDefaults.integerForKey(Settings.Notification.Interval.key())) " +  NSLocalizedString("hours", comment: "")
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
            actionSheet?.addButtonWithTitle(UnitsOfMeasure.Liters.nameForUnitOfMeasure(), type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(UnitsOfMeasure.Liters.rawValue, forKey: Settings.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
            actionSheet?.addButtonWithTitle(UnitsOfMeasure.Ounces.nameForUnitOfMeasure(), type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(UnitsOfMeasure.Ounces.rawValue, forKey: Settings.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
        }
        if (indexPath.section == 2 && indexPath.row == 1) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("from:", comment: ""))
            for index in 5...22 {
                actionSheet?.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                    self.updateNotificationSetting(Settings.Notification.From.key(), value: index)
                })
            }
        }
        if (indexPath.section == 2 && indexPath.row == 2) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("to:", comment: ""))
            let upper = self.userDefaults.integerForKey(Settings.Notification.From.key()) + 1
            for index in upper...24 {
                actionSheet?.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                    self.updateNotificationSetting(Settings.Notification.To.key(), value: index)
                })
            }
        }
        if (indexPath.section == 2 && indexPath.row == 3) {
            actionSheet = AHKActionSheet(title: NSLocalizedString("every:", comment: ""))
            for index in 1...8 {
                let hour = index > 1 ? NSLocalizedString("hours", comment: "") : NSLocalizedString("hour", comment: "")
                actionSheet?.addButtonWithTitle("\(index) \(hour)", type: .Default, handler: { (actionSheet) -> Void in
                    self.updateNotificationSetting(Settings.Notification.Interval.key(), value: index)
                })
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

    @IBAction func reminderAction(sender: UISwitch) {
        userDefaults.setBool(sender.on, forKey: Settings.Notification.On.key())
        userDefaults.synchronize()
        self.tableView.reloadData()
        updateNotificationPreferences()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 3
        } else {
            if NSUserDefaults.groupUserDefaults().boolForKey(Settings.Notification.On.key()) {
                return 4
            } else {
                return 1
            }
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == smallPortionText) {
            storeText(smallPortionText, toKey: Settings.Gulp.Small.key())
        }
        if (textField == largePortionText) {
            storeText(largePortionText, toKey: Settings.Gulp.Big.key())
        }
        if (textField == dailyGoalText) {
            storeText(dailyGoalText, toKey: Settings.Gulp.Goal.key())
        }
    }

    func storeText(textField: UITextField, toKey key: String) {
        let number = numberFormatter.numberFromString(textField.text) as? Double
        userDefaults.setDouble(number ?? 0.0, forKey: key)
        userDefaults.synchronize()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
