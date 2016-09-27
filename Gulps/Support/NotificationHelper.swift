import Foundation
import UIKit

class NotificationHelper {

  /// Version 1.4 introduces a new sound. Users from previous versions need to reschedule the local notifications
  class func rescheduleNotifications() {
    let userDefaults = UserDefaults.groupUserDefaults()
    if (!userDefaults.bool(forKey: Constants.Notification.on.key())) {
      return
    }
    unscheduleNotifications()
    registerNotifications()
  }

  class func registerNotifications() {
    let userDefaults = UserDefaults.groupUserDefaults()
    if (!userDefaults.bool(forKey: Constants.Notification.on.key())) {
      return
    }

    let startHour = userDefaults.integer(forKey: Constants.Notification.from.key())
    let endHour = userDefaults.integer(forKey: Constants.Notification.to.key())
    let interval = userDefaults.integer(forKey: Constants.Notification.interval.key())

    var hour = startHour
    while (hour < endHour) {
      let cal = Calendar(identifier: Calendar.Identifier.gregorian)
      let date = (cal as NSCalendar).date(bySettingHour: hour, minute: 0, second: 0, of: Date(), options: NSCalendar.Options())
      let reminder = UILocalNotification()

      reminder.fireDate = date
      reminder.repeatInterval = NSCalendar.Unit.day
      reminder.alertBody = NSLocalizedString("notification text", comment: "")
      reminder.alertAction = "Ok"
      reminder.soundName = "drop.caf"
      reminder.category = "GULP_CATEGORY"

      UIApplication.shared.scheduleLocalNotification(reminder)

      hour += interval
    }
  }

  class func unscheduleNotifications() {
    UIApplication.shared.scheduledLocalNotifications?.removeAll(keepingCapacity: false)
  }

  class func askPermission() {
    let smallAction = UIMutableUserNotificationAction()
    smallAction.identifier = "SMALL_ACTION"
    smallAction.title = "Small Gulp"
    smallAction.activationMode = .background
    smallAction.isAuthenticationRequired = false
    smallAction.isDestructive = false

    let bigAction = UIMutableUserNotificationAction()
    bigAction.identifier = "BIG_ACTION"
    bigAction.title = "Big Gulp"
    bigAction.activationMode = .background
    bigAction.isAuthenticationRequired = false
    bigAction.isDestructive = false

    let gulpCategory = UIMutableUserNotificationCategory()
    gulpCategory.identifier = "GULP_CATEGORY"
    gulpCategory.setActions([smallAction, bigAction], for: .default)
    gulpCategory.setActions([smallAction, bigAction], for: .minimal)

    let categories = NSSet(object: gulpCategory) as! Set<UIUserNotificationCategory>
    let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: categories)
    UIApplication.shared.registerUserNotificationSettings(settings)
  }

  class func handleNotification(_ notification: UILocalNotification, identifier: String) {
    if (notification.category == "GULP_CATEGORY") {
      if (identifier == "BIG_ACTION") {
        NotificationHelper.addGulp(Constants.Gulp.big.key())
      }
      if (identifier == "SMALL_ACTION") {
        NotificationHelper.addGulp(Constants.Gulp.small.key())
      }
    }
  }

  class func addGulp(_ size: String) {
    EntryHandler.sharedHandler.addGulp(UserDefaults.groupUserDefaults().double(forKey: size))
  }
}
