import Foundation

enum UnitsOfMeasure: Int {
    case Liters, Ounces

    func nameForUnitOfMeasure() -> String {
        switch self {
        case .Liters:
            return "Liters"
        case .Ounces:
            return "Ounces"
        }
    }

    func suffixForUnitOfMeasure() -> String {
        switch self {
        case .Liters:
            return "L"
        case .Ounces:
            return "Oz"
        }
    }
}

public class Settings {

    public enum General: Int {
        case UnitOfMeasure, OnboardingShown

        public func key() -> String {
            switch self {
            case .UnitOfMeasure:
                return "UNIT_OF_MEASURE"
            case .OnboardingShown:
                return "ONBOARDING_SHOWN"
            }
        }
    }

    public enum Gulp: Int {
        case Big, Small, Goal
        public func key() -> String {
            switch self {
            case .Big:
                return "GULP_BIG"
            case .Small:
                return "GULP_SMALL"
            case .Goal:
                return "PORTION_GOAL"
            }
        }
    }

    public enum Notification: Int {
        case On, From, To, Interval
        public func key() -> String {
            switch self {
            case .On:
                return "NOTIFICATION_ON"
            case .From:
                return "NOTIFICATION_FROM"
            case .To:
                return "NOTIFICATION_TO"
            case .Interval:
                return "NOTIFICATION_INTERVAL"
            }
        }
    }

    public class func registerDefaults() {
        let userDefaults = NSUserDefaults.groupUserDefaults()

        // The defaults registered with registerDefaults are ignore by the Today Extension. :/
        if (!userDefaults.boolForKey("DEFAULTS_INSTALLED")) {
            userDefaults.setBool(true, forKey: "DEFAULTS_INSTALLED")
            userDefaults.setInteger(UnitsOfMeasure.Liters.rawValue, forKey: General.UnitOfMeasure.key())
            userDefaults.setDouble(0.5, forKey: Gulp.Big.key())
            userDefaults.setDouble(0.2, forKey: Gulp.Small.key())
            userDefaults.setDouble(2, forKey: Gulp.Goal.key())
            userDefaults.setBool(true, forKey: Notification.On.key())
            userDefaults.setInteger(10, forKey: Notification.From.key())
            userDefaults.setInteger(22, forKey: Notification.To.key())
            userDefaults.setInteger(2, forKey: Notification.Interval.key())
        }
        userDefaults.synchronize()
    }
    
    public class func registerDefaultsForLiter() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        userDefaults.setDouble(0.5, forKey: Gulp.Big.key())
        userDefaults.setDouble(0.2, forKey: Gulp.Small.key())
        userDefaults.setDouble(2, forKey: Gulp.Goal.key())
        userDefaults.synchronize()
    }
    
    public class func registerDefaultsForOunces() {
        let userDefaults = NSUserDefaults.groupUserDefaults()
        userDefaults.setDouble(16, forKey: Gulp.Big.key())
        userDefaults.setDouble(8, forKey: Gulp.Small.key())
        userDefaults.setDouble(64, forKey: Gulp.Goal.key())
        userDefaults.synchronize()
    }
}
