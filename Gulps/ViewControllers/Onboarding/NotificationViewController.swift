import UIKit
import AHKActionSheet

class NotificationViewController: OnboardingViewController, UIActionSheetDelegate {

  @IBOutlet weak var notificationSwitch: UISwitch!
  @IBOutlet weak var fromLabel: UILabel!
  @IBOutlet weak var intervalLabel: UILabel!
  @IBOutlet weak var toLabel: UILabel!
  let userDefaults = UserDefaults.groupUserDefaults()

  lazy var fromActionSheet: AHKActionSheet = {
    var actionSheet = AHKActionSheet(title: NSLocalizedString("from:", comment: ""))
    for index in 5...22 {
      actionSheet?.addButton(withTitle: "\(index):00", type: .default) { _ in
        self.userDefaults.set(index, forKey: Constants.Notification.from.key())
        self.userDefaults.synchronize()
        self.updateUI()
      }
    }
    return actionSheet!
  }()

  lazy var intervalActionSheet: AHKActionSheet = {
    var actionSheet = AHKActionSheet(title: NSLocalizedString("every:", comment: ""))
    for index in 1...8 {
      let hour = index > 1 ? NSLocalizedString("hours", comment: "") : NSLocalizedString("hour", comment: "")
      actionSheet?.addButton(withTitle: "\(index) \(hour)", type: .default) { _ in
        self.userDefaults.set(index, forKey: Constants.Notification.interval.key())
        self.userDefaults.synchronize()
        self.updateUI()
      }
    }
    return actionSheet!
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func updateUI() {
    self.fromLabel.text = "\(self.userDefaults.integer(forKey: Constants.Notification.from.key())):00"
    self.toLabel.text = "\(self.userDefaults.integer(forKey: Constants.Notification.to.key())):00"
    let interval = self.userDefaults.integer(forKey: Constants.Notification.interval.key())
    let hour = interval > 1 ? NSLocalizedString("hours", comment: "") : NSLocalizedString("hour", comment: "")
    self.intervalLabel.text = "\(interval) \(hour)"
    self.notificationSwitch.isOn = self.userDefaults.bool(forKey: Constants.Notification.on.key())
  }

  @IBAction func openFromSelection(_ sender: UIButton) {
    self.fromActionSheet.show()
  }

  @IBAction func openIntervalSelection(_ sender: UIButton) {
    self.intervalActionSheet.show()
  }

  @IBAction func openToSelection(_ sender: UIButton) {
    let toActionSheet = AHKActionSheet(title: NSLocalizedString("to:", comment: ""))
    let upper = self.userDefaults.integer(forKey: Constants.Notification.from.key()) + 1
    for index in upper...24 {
      toActionSheet!.addButton(withTitle: "\(index):00", type: .default) { _ in
        self.userDefaults.set(index, forKey: Constants.Notification.to.key())
        self.userDefaults.synchronize()
        self.updateUI()
      }
    }
    toActionSheet?.show()
  }

  @IBAction func enableNotifications(_ sender: UISwitch) {
    self.userDefaults.set(sender.isOn, forKey: Constants.Notification.on.key())
    self.userDefaults.synchronize()
  }

  @IBAction func doneAction() {
    userDefaults.set(true, forKey: Constants.General.onboardingShown.key())
    NotificationHelper.unscheduleNotifications()
    if notificationSwitch.isOn {
      NotificationHelper.askPermission()
    }

    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.loadMainInterface()
    }
  }
}
