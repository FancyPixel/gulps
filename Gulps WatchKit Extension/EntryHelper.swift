import Foundation

class EntryHelper {
    static let sharedHelper = EntryHelper()
    lazy var userDefaults = NSUserDefaults.standardUserDefaults()

    func saveSettings(goal goal: Double, current: Double, small: Double, big: Double) {
        userDefaults.setDouble(goal, forKey: Constants.Gulp.Goal.key())
        userDefaults.setDouble(small, forKey: Constants.Gulp.Small.key())
        userDefaults.setDouble(big, forKey: Constants.Gulp.Big.key())
        userDefaults.setDouble(current, forKey: "CURRENT")
        userDefaults.synchronize()
    }

    func percentage() -> Int {
        let userDefaults = NSUserDefaults()
        let quantity = userDefaults.doubleForKey("CURRENT")
        let goal = userDefaults.doubleForKey(Constants.Gulp.Goal.key())
        if goal == 0 {
            return 0
        } else {
            return Int((quantity / goal) * 100.0)
        }
    }
}