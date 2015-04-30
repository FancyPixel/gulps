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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preferences"
        for element in [self.smallPortionText, self.largePortionText, self.dailyGoalText] {
            element.inputAccessoryView = Globals.numericToolbar(element,
                selector: Selector("resignFirstResponder"),
                barColor: UIColor.mainColor(),
                textColor: UIColor.whiteColor())
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
        if let unit = UnitsOfMeasure(rawValue: self.userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
            self.unitOfMesureLabel.text = unit.nameForUnitOfMeasure()
            suffix = unit.suffixForUnitOfMeasure()
        }

        self.uomLabels.map({$0.text = suffix})
        self.largePortionText.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Settings.Gulp.Big.key()))
        self.smallPortionText.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Settings.Gulp.Small.key()))
        self.dailyGoalText.text = numberFormatter.stringFromNumber(self.userDefaults.doubleForKey(Settings.Gulp.Goal.key()))

        self.notificationSwitch.on = self.userDefaults.boolForKey(Settings.Notification.On.key())
        self.notificationFromLabel.text = "\(self.userDefaults.integerForKey(Settings.Notification.From.key())):00"
        self.notificationToLabel.text = "\(self.userDefaults.integerForKey(Settings.Notification.To.key())):00"
        self.notificationIntervalLabel.text = "\(self.userDefaults.integerForKey(Settings.Notification.Interval.key())) hours"
    }

    func updateNotificationPreferences() {
        if (self.notificationSwitch.on) {
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
        let userDefaults = NSUserDefaults.groupUserDefaults()

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
            if (NSUserDefaults.groupUserDefaults().boolForKey(Settings.Notification.On.key())) {
                return 4
            } else {
                return 1
            }
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if (textField == self.smallPortionText) {
            var small = 0.0
            if let number = numberFormatter.numberFromString(self.smallPortionText.text) {
                small = number as Double
            }
            self.userDefaults.setDouble(small, forKey: Settings.Gulp.Small.key())
            self.userDefaults.synchronize()
        }
        if (textField == self.largePortionText) {
            var big = 0.0
            if let number = numberFormatter.numberFromString(self.largePortionText.text) {
                big = number as Double
            }
            self.userDefaults.setDouble(big, forKey: Settings.Gulp.Big.key())
            self.userDefaults.synchronize()
        }
        if (textField == self.dailyGoalText) {
            var goal = 0.0
            if let number = numberFormatter.numberFromString(self.dailyGoalText.text) {
                goal = number as Double
            }
            self.userDefaults.setDouble(goal, forKey: Settings.Gulp.Goal.key())
            self.userDefaults.synchronize()
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
