import Foundation

class EntryHelper {
    static let sharedHelper = EntryHelper()
    lazy var userDefaults = NSUserDefaults.standardUserDefaults()

    func saveSettings(goal goal: Double, current: Double, small: Double, big: Double) {
        userDefaults.setDouble(goal, forKey: Constants.Gulp.Goal.key())
        userDefaults.setDouble(small, forKey: Constants.Gulp.Small.key())
        userDefaults.setDouble(big, forKey: Constants.Gulp.Big.key())
        userDefaults.setDouble(current, forKey: Constants.WatchContext.Current.key())
        userDefaults.synchronize()
    }

    func addGulp(portion: String) {
        let quantity = userDefaults.doubleForKey(Constants.WatchContext.Current.key())
        let portion = userDefaults.doubleForKey(portion)
        userDefaults.setDouble(quantity + portion, forKey: Constants.WatchContext.Current.key())
    }

    func cachedData(newData data: String) -> [[String: AnyObject]] {
        if var cache = userDefaults.objectForKey(Constants.WatchContext.Cached.key()) as? [[String: AnyObject]] {
            cache.append(["gulp": data, "date": NSDate()])
            return cache
        }
        return [["gulp": data, "date": NSDate()]]
    }

    func percentage() -> Int? {
        guard userDefaults.doubleForKey(Constants.Gulp.Goal.key()) != 0 else {
            return nil
        }

        let quantity = userDefaults.doubleForKey(Constants.WatchContext.Current.key())
        let goal = userDefaults.doubleForKey(Constants.Gulp.Goal.key())
        return Int((quantity / goal) * 100.0)
    }
}