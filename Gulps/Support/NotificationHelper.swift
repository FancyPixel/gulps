import Foundation
import UIKit

class NotificationHelper {

  /// Version 1.4 introduces a new sound. Users from previous versions need to reschedule the local notifications
  class func rescheduleNotifications() {
    let userDefaults = NSUserDefaults.groupUserDefaults()
    if (!userDefaults.boolForKey(Constants.Notification.On.key())) {
      return
    }
    unscheduleNotifications()
    registerNotifications()
  }

  class func registerNotifications() {
    let userDefaults = NSUserDefaults.groupUserDefaults()
    if (!userDefaults.boolForKey(Constants.Notification.On.key())) {
      return
    }

    let startHour = userDefaults.integerForKey(Constants.Notification.From.key())
    let endHour = userDefaults.integerForKey(Constants.Notification.To.key())
    let interval = userDefaults.integerForKey(Constants.Notification.Interval.key())

    var hour = startHour
    while (hour < endHour) {
      let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
      let date = cal.dateBySettingHour(hour, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
      let reminder = UILocalNotification()

      reminder.fireDate = date
      reminder.repeatInterval = NSCalendarUnit.Day
      reminder.alertBody = NSLocalizedString("notification text", comment: "")
      reminder.alertAction = "Ok"
      reminder.soundName = "drop.caf"
      reminder.category = "GULP_CATEGORY"

      UIApplication.sharedApplication().scheduleLocalNotification(reminder)

      hour += interval
    }
  }

  class func unscheduleNotifications() {
    UIApplication.sharedApplication().scheduledLocalNotifications?.removeAll(keepCapacity: false)
  }

  class func askPermission() {
    let smallAction = UIMutableUserNotificationAction()
    smallAction.identifier = "SMALL_ACTION"
    smallAction.title = "Small Gulp"
    smallAction.activationMode = .Background
    smallAction.authenticationRequired = false
    smallAction.destructive = false

    let bigAction = UIMutableUserNotificationAction()
    bigAction.identifier = "BIG_ACTION"
    bigAction.title = "Big Gulp"
    bigAction.activationMode = .Background
    bigAction.authenticationRequired = false
    bigAction.destructive = false

    let gulpCategory = UIMutableUserNotificationCategory()
    gulpCategory.identifier = "GULP_CATEGORY"
    gulpCategory.setActions([smallAction, bigAction], forContext: .Default)
    gulpCategory.setActions([smallAction, bigAction], forContext: .Minimal)

    let categories = NSSet(object: gulpCategory) as! Set<UIUserNotificationCategory>
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: categories)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }

  class func handleNotification(notification: UILocalNotification, identifier: String) {
    if (notification.category == "GULP_CATEGORY") {
      if (identifier == "BIG_ACTION") {
        NotificationHelper.addGulp(Constants.Gulp.Big.key())
      }
      if (identifier == "SMALL_ACTION") {
        NotificationHelper.addGulp(Constants.Gulp.Small.key())
      }
    }
  }

  class func addGulp(size: String) {
    EntryHandler.sharedHandler.addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(size))
  }
}
