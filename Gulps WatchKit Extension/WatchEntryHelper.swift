import Foundation

class WatchEntryHelper {
    static let sharedHelper = WatchEntryHelper()
    lazy var userDefaults = NSUserDefaults.standardUserDefaults()

    /**
     Save settings received by
     - parameter goal: The daily goal
     - parameter current: The current progress
     - parameter small: The small portion size
     - parameter big: The big portion size
     */
    func saveSettings(goal goal: Double, current: Double, small: Double, big: Double) {
        userDefaults.setDouble(goal, forKey: Constants.Gulp.Goal.key())
        userDefaults.setDouble(small, forKey: Constants.Gulp.Small.key())
        userDefaults.setDouble(big, forKey: Constants.Gulp.Big.key())
        userDefaults.setObject(NSDate(), forKey: Constants.WatchContext.Date.key())
        userDefaults.setDouble(current, forKey: Constants.WatchContext.Current.key())
        userDefaults.synchronize()
    }

    /**
     Save settings received by
     - parameter portion: The portion key
     */
    func addGulp(portion: String) {
        let portion = userDefaults.doubleForKey(portion)
        userDefaults.setDouble(quantity() + portion, forKey: Constants.WatchContext.Current.key())
        userDefaults.setObject(NSDate(), forKey: Constants.WatchContext.Date.key())
        userDefaults.synchronize()
    }

    /**
     Application Context sent by the watch
     - Returns: [String: Double]
     */
    func applicationContext() -> [String: Double] {
        return [
            Constants.Gulp.Goal.key(): userDefaults.doubleForKey(Constants.Gulp.Goal.key()),
            Constants.WatchContext.Current.key(): quantity(),
            Constants.Gulp.Small.key(): userDefaults.doubleForKey(Constants.Gulp.Small.key()),
            Constants.Gulp.Big.key(): userDefaults.doubleForKey(Constants.Gulp.Big.key())]
    }

    /**
     Returns the current quantity
     It also checks if the data is stale, resetting the quantity if needed
     - Returns: Double the current quantity
     */
    func quantity() -> Double {
        let quantity = userDefaults.doubleForKey(Constants.WatchContext.Current.key())

        if let date = userDefaults.objectForKey(Constants.WatchContext.Date.key()) as? NSDate {
            if let tomorrow = date.startOfTomorrow where NSDate().compare(tomorrow) != NSComparisonResult.OrderedAscending {
                // Data is stale, reset the counter
                return 0
            }
        }

        return quantity
    }

    /**
     Returns the current percentage, if available
     The data might not be there yet (app just installed)
     - Returns: Int? the current percentage
     */
    func percentage() -> Int? {
        let goal = userDefaults.doubleForKey(Constants.Gulp.Goal.key())
        return Int(round(quantity() / goal * 100.0))
    }
}
