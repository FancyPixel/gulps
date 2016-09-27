import Foundation
import RealmSwift

/**
 An Entry represents an entire day worth of input
 */
open class Entry: Object {
  dynamic open var date = Entry.defaultDate()
  dynamic open var quantity = 0.0
  dynamic open var percentage = 0.0
  dynamic open var goal = 0.0
  open let gulps = List<Gulp>()

  /**
   The date is the primary key. `defaultDate` provides the current day in string format.
   The string format is required by Realm for primary keys
   */
  class func defaultDate() -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    return dateFormat.string(from: Date())
  }

  override open class func primaryKey() -> String {
    return "date"
  }

  /**
   Adds a portion of water to the current day
   - parameter quantity: The portion size
   - parameter goal: The daily goal
   - parameter date: The date of the portion
   */
  func addGulp(_ quantity: Double, goal: Double, date: Date?) {
    let gulp = Gulp(quantity: quantity)
    self.gulps.append(gulp)
    self.quantity += quantity
    self.goal = goal
    if let date = date {
      gulp.date = date
    }
    if goal > 0 {
      self.percentage = (self.quantity / self.goal) * 100.0
    }
  }

  /**
   Removes the last portion
   */
  func removeLastGulp() {
    if let gulp = self.gulps.last {
      self.quantity -= gulp.quantity
      if goal > 0 {
        self.percentage = (self.quantity / self.goal) * 100.0
      }
      if (self.percentage < 0) {
        self.percentage = 0
      }
      self.gulps.removeLast()
    }
  }

  /**
   Returns the formatted percentage value
   - returns: String
   */
  func formattedPercentage() -> String {
    return percentage.formattedPercentage()
  }
}
