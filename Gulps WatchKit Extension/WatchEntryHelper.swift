import Foundation

class WatchEntryHelper {
  static let sharedHelper = WatchEntryHelper()
  lazy var userDefaults = UserDefaults.standard

  /**
   Save settings received from the phone
   - parameter goal: The daily goal
   - parameter current: The current progress
   - parameter small: The small portion size
   - parameter big: The big portion size
   */
  func saveSettings(goal: Double, current: Double, small: Double, big: Double) {
    userDefaults.set(goal, forKey: Constants.Gulp.goal.key())
    userDefaults.set(small, forKey: Constants.Gulp.small.key())
    userDefaults.set(big, forKey: Constants.Gulp.big.key())
    userDefaults.set(Date(), forKey: Constants.WatchContext.date.key())
    userDefaults.set(current, forKey: Constants.WatchContext.current.key())
    userDefaults.synchronize()
  }

  /**
   Save settings received from the phone
   - parameter portion: The portion key
   */
  func addGulp(_ portion: String) {
    let portion = userDefaults.double(forKey: portion)
    userDefaults.set(quantity() + portion, forKey: Constants.WatchContext.current.key())
    userDefaults.set(Date(), forKey: Constants.WatchContext.date.key())
    userDefaults.synchronize()
  }

  /**
   Application Context sent by the watch
   - Returns: [String: Double]
   */
  func applicationContext() -> [String: Double] {
    return [
      Constants.Gulp.goal.key(): userDefaults.double(forKey: Constants.Gulp.goal.key()),
      Constants.WatchContext.current.key(): quantity(),
      Constants.Gulp.small.key(): userDefaults.double(forKey: Constants.Gulp.small.key()),
      Constants.Gulp.big.key(): userDefaults.double(forKey: Constants.Gulp.big.key())]
  }

  /**
   Returns the current quantity
   It also checks if the data is stale, resetting the quantity if needed
   - Returns: Double the current quantity
   */
  func quantity() -> Double {
    let quantity = userDefaults.double(forKey: Constants.WatchContext.current.key())

    if let date = userDefaults.object(forKey: Constants.WatchContext.date.key()) as? Date {
      if let tomorrow = date.startOfTomorrow , Date().compare(tomorrow) != ComparisonResult.orderedAscending {
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
    let goal = userDefaults.double(forKey: Constants.Gulp.goal.key())
    return Int(round(quantity() / goal * 100.0))
  }
}
