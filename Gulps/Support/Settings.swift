import Foundation

open class Settings {
  open class func registerDefaults() {
    let userDefaults = UserDefaults.groupUserDefaults()

    // The defaults registered with registerDefaults are ignore by the Today Extension. :/
    if (!userDefaults.bool(forKey: "DEFAULTS_INSTALLED")) {
      userDefaults.set(true, forKey: "DEFAULTS_INSTALLED")
      userDefaults.set(Constants.UnitsOfMeasure.liters.rawValue, forKey: Constants.General.unitOfMeasure.key())
      userDefaults.set(0.5, forKey: Constants.Gulp.big.key())
      userDefaults.set(0.2, forKey: Constants.Gulp.small.key())
      userDefaults.set(2, forKey: Constants.Gulp.goal.key())
      userDefaults.set(false, forKey: Constants.Health.on.key())
      userDefaults.set(true, forKey: Constants.Notification.on.key())
      userDefaults.set(10, forKey: Constants.Notification.from.key())
      userDefaults.set(22, forKey: Constants.Notification.to.key())
      userDefaults.set(2, forKey: Constants.Notification.interval.key())
    }
    userDefaults.synchronize()
  }

  open class func registerDefaultsForLiter() {
    let userDefaults = UserDefaults.groupUserDefaults()
    userDefaults.set(0.5, forKey: Constants.Gulp.big.key())
    userDefaults.set(0.2, forKey: Constants.Gulp.small.key())
    userDefaults.set(2, forKey: Constants.Gulp.goal.key())
    userDefaults.synchronize()
  }

  open class func registerDefaultsForOunces() {
    let userDefaults = UserDefaults.groupUserDefaults()
    userDefaults.set(16, forKey: Constants.Gulp.big.key())
    userDefaults.set(8, forKey: Constants.Gulp.small.key())
    userDefaults.set(64, forKey: Constants.Gulp.goal.key())
    userDefaults.synchronize()
  }

  open class func watchData(current: Double) -> [String: Double] {
    let userDefaults = UserDefaults.groupUserDefaults()
    return [
      Constants.Gulp.goal.key(): userDefaults.double(forKey: Constants.Gulp.goal.key()),
      Constants.WatchContext.current.key(): current,
      Constants.Gulp.small.key(): userDefaults.double(forKey: Constants.Gulp.small.key()),
      Constants.Gulp.big.key(): userDefaults.double(forKey: Constants.Gulp.big.key())]
  }
}
