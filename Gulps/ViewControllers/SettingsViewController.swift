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
        self.title = "Preferences"
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
        notificationIntervalLabel.text = "\(userDefaults.integerForKey(Settings.Notification.Interval.key())) hours"
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

        if (indexPath.section == 0 && indexPath.row == 0) {
            let toActionSheet = AHKActionSheet(title: "Unit Of Measure:")
            toActionSheet!.addButtonWithTitle(UnitsOfMeasure.Liters.nameForUnitOfMeasure(), type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(UnitsOfMeasure.Liters.rawValue, forKey: Settings.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
            toActionSheet!.addButtonWithTitle(UnitsOfMeasure.Ounces.nameForUnitOfMeasure(), type: .Default, handler: { (actionSheet) -> Void in
                self.userDefaults.setInteger(UnitsOfMeasure.Ounces.rawValue, forKey: Settings.General.UnitOfMeasure.key())
                self.userDefaults.synchronize()
                self.updateUI()
            })
            toActionSheet.show()
        }
        if (indexPath.section == 2 && indexPath.row == 1) {
            var actionSheet = AHKActionSheet(title: "From:")
            for index in 5...22 {
                actionSheet.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                    self.userDefaults.setInteger(index, forKey: Settings.Notification.From.key())
                    self.userDefaults.synchronize()
                    self.updateUI()
                    self.updateNotificationPreferences()
                })
            }
            actionSheet.show()
        }
        if (indexPath.section == 2 && indexPath.row == 2) {
            let toActionSheet = AHKActionSheet(title: "To:")
            let upper = self.userDefaults.integerForKey(Settings.Notification.From.key()) + 1
            for index in upper...24 {
                toActionSheet!.addButtonWithTitle("\(index):00", type: .Default, handler: { (actionSheet) -> Void in
                    self.userDefaults.setInteger(index, forKey: Settings.Notification.To.key())
                    self.userDefaults.synchronize()
                    self.updateUI()
                    self.updateNotificationPreferences()
                })
            }
            toActionSheet.show()
        }
        if (indexPath.section == 2 && indexPath.row == 3) {
            var actionSheet = AHKActionSheet(title: "Every:")
            for index in 1...8 {
                let hour = index > 1 ? "hours" : "hour"
                actionSheet.addButtonWithTitle("\(index) \(hour)", type: .Default, handler: { (actionSheet) -> Void in
                    self.userDefaults.setInteger(index, forKey: Settings.Notification.Interval.key())
                    self.userDefaults.synchronize()
                    self.updateUI()
                    self.updateNotificationPreferences()
                })
            }
            actionSheet.show()
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    @IBAction func reminderAction(sender: UISwitch) {
        userDefaults.setBool(sender.on, forKey: Settings.Notification.On.key())
        userDefaults.synchronize()
        self.tableView.reloadData()
        // This crashes if you touch the switch and drag...
        //        let indexes = [NSIndexPath(forRow: 1, inSection: 2), NSIndexPath(forRow: 2, inSection: 2), NSIndexPath(forRow: 3, inSection: 2)]
        //        self.tableView.beginUpdates()
        //        if (sender.on) {
        //            self.tableView.insertRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
        //        } else {
        //            self.tableView.deleteRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
        //        }
        //        self.tableView.endUpdates()
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
