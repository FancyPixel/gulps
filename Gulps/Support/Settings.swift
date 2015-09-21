import Foundation
import WatchConnectivity

public class Settings {
    public class func registerDefaults() {
        let userDefaults = NSUserDefaults.groupUserDefaults()

        // The defaults registered with registerDefaults are ignore by the Today Extension. :/
        if (!userDefaults.boolForKey("DEFAULTS_INSTALLED")) {
            userDefaults.setBool(true, forKey: "DEFAULTS_INSTALLED")
            userDefaults.setInteger(Constants.UnitsOfMeasure.Liters.rawValue, forKey: Constants.General.UnitOfMeasure.key())
            userDefaults.setDouble(0.5, forKey: Constants.Gulp.Big.key())
            userDefaults.setDouble(0.2, forKey: Constants.Gulp.Small.key())
            userDefaults.setDouble(2, forKey: Constants.Gulp.Goal.key())
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

    /**
    `WatchSettings` holds the basic settings needed by the Watch app:
    - `Gulp.Big`: The Big portion size
    - `Gulp.Small`: The Small portion size
    - `Gulp.Goal`: The daiyGoal
    */
    typealias WatchSettings = [String: Double]

    /**
    Exports the current settings' subset needed by the Watch app
    - Returns: `WatchSettings`
    */
    class func settingsForWatch() -> WatchSettings {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        var settings = WatchSettings()

        for key in [Constants.Gulp.Big.key(), Constants.Gulp.Small.key(), Constants.Gulp.Goal.key()] {
            settings[key] = userDefaults.doubleForKey(key)
        }
        return settings
    }

    /** 
    Transfer the settings to the Watch app
    - Parameter session: WCSession instance
    */
    @available(iOS 9.0, *)
    @available(iOSApplicationExtension 9.0, *)
    public class func pushSettings(session: WCSession) {
        for transfer in session.outstandingUserInfoTransfers {
            if let settings = transfer.userInfo["settings"] as? WCSessionUserInfoTransfer {
                settings.cancel()
            }
        }

        if session.watchAppInstalled {
            session.transferUserInfo(["settings": settingsForWatch()])
        }
    }
}
