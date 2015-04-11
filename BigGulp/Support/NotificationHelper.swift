import Foundation

class NotificationHelper {

    class func registerNotifications() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        if (!userDefaults.boolForKey(Settings.Notification.On.key())) {
            return
        }

        let startHour = userDefaults.integerForKey(Settings.Notification.From.key())
        let endHour = userDefaults.integerForKey(Settings.Notification.To.key())
        let interval = userDefaults.integerForKey(Settings.Notification.Interval.key())

        var hour = startHour
        while (hour < endHour) {
            let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let date = cal.dateBySettingHour(hour, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
            let reminder = UILocalNotification()

            reminder.fireDate = date
            reminder.repeatInterval = NSCalendarUnit.CalendarUnitDay
            reminder.alertBody = "Remember to drink some water!"
            reminder.alertAction = "Ok"
            reminder.soundName = "sound.aif"
            reminder.category = "GULP_CATEGORY"

            UIApplication.sharedApplication().scheduleLocalNotification(reminder)

            hour += interval
        }
    }

    class func unscheduleNotifications() {
        UIApplication.sharedApplication().scheduledLocalNotifications.removeAll(keepCapacity: false)
    }

    class func askPermission() {
        let smallAction = UIMutableUserNotificationAction()
        smallAction.identifier = "SMALL_ACTION"
        smallAction.title = "Small Gulp"
        smallAction.activationMode = .Background
        smallAction.authenticationRequired = true
        smallAction.destructive = false

        let bigAction = UIMutableUserNotificationAction()
        bigAction.identifier = "BIG_ACTION"
        bigAction.title = "Big Gulp"
        bigAction.activationMode = .Background
        bigAction.authenticationRequired = true
        bigAction.destructive = false

        let gulpCategory = UIMutableUserNotificationCategory()
        gulpCategory.identifier = "GULP_CATEGORY"
        gulpCategory.setActions([smallAction, bigAction], forContext: .Default)
        gulpCategory.setActions([smallAction, bigAction], forContext: .Minimal)

        let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: gulpCategory) as Set<NSObject>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

    class func handleNotification(notification: UILocalNotification, identifier: String) {
        if (notification.category == "GULP_CATEGORY") {
            if (identifier == "BIG_ACTION") {
                NotificationHelper.addGulp(Settings.Gulp.Big.key())
            }
            if (identifier == "SMALL_ACTION") {
                NotificationHelper.addGulp(Settings.Gulp.Small.key())
            }
        }
    }

    class func addGulp(size: String) {
        EntryHandler().addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(size))
         MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp").passMessageObject("todayUpdate", identifier: "mainUpdate")
    }
}
