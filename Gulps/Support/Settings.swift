import Foundation

public class Settings {
    public class func registerDefaults() {
        let userDefaults = NSUserDefaults.groupUserDefaults()

        // The defaults registered with registerDefaults are ignored by the Today Extension.
        if (!userDefaults.boolForKey("DEFAULTS_INSTALLED")) {
            userDefaults.setBool(true, forKey: "DEFAULTS_INSTALLED")
            userDefaults.setInteger(Constants.UnitsOfMeasure.Liters.rawValue, forKey: Constants.General.UnitOfMeasure.key())
            userDefaults.setDouble(0.5, forKey: Constants.Gulp.Big.key())
            userDefaults.setDouble(0.2, forKey: Constants.Gulp.Small.key())
            userDefaults.setDouble(2, forKey: Constants.Gulp.Goal.key())
            userDefaults.setBool(false, forKey: Constants.Health.On.key())
            userDefaults.setBool(true, forKey: Constants.Notification.On.key())
            userDefaults.setInteger(10, forKey: Constants.Notification.From.key())
            userDefaults.setInteger(22, forKey: Constants.Notification.To.key())
            userDefaults.setInteger(2, forKey: Constants.Notification.Interval.key())
        }
        userDefaults.synchronize()
    }

    public class func registerDefaultsForLiter() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        userDefaults.setDouble(0.5, forKey: Constants.Gulp.Big.key())
        userDefaults.setDouble(0.2, forKey: Constants.Gulp.Small.key())
        userDefaults.setDouble(2, forKey: Constants.Gulp.Goal.key())
        userDefaults.synchronize()
    }

    public class func registerDefaultsForOunces() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        userDefaults.setDouble(16, forKey: Constants.Gulp.Big.key())
        userDefaults.setDouble(8, forKey: Constants.Gulp.Small.key())
        userDefaults.setDouble(64, forKey: Constants.Gulp.Goal.key())
        userDefaults.synchronize()
    }

    public class func watchData(current current: Double) -> [String: Double] {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        return [
            Constants.Gulp.Goal.key(): userDefaults.doubleForKey(Constants.Gulp.Goal.key()),
            Constants.WatchContext.Current.key(): current,
            Constants.Gulp.Small.key(): userDefaults.doubleForKey(Constants.Gulp.Small.key()),
            Constants.Gulp.Big.key(): userDefaults.doubleForKey(Constants.Gulp.Big.key())]
    }
}
