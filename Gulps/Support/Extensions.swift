import Foundation
import UIKit

extension NSUserDefaults {
  class func groupUserDefaults() -> NSUserDefaults {
    return NSUserDefaults(suiteName: "group.\(Constants.bundle())")!
  }
}

extension Double {
  func formattedPercentage() -> String {
    let percentageFormatter = NSNumberFormatter()
    percentageFormatter.numberStyle = .PercentStyle
    return percentageFormatter.stringFromNumber(round(self) / 100.0) ?? "\(self)%"
  }
}

extension NSRange {
  func toRange(string: String) -> Range<String.Index> {
    let startIndex = string.startIndex.advancedBy(location)
    let endIndex = startIndex.advancedBy(length)
    return startIndex..<endIndex
  }
}

extension NSDate {
  var startOfDay: NSDate {
    return NSCalendar.currentCalendar().startOfDayForDate(self)
  }

  var startOfTomorrow: NSDate? {
    let components = NSDateComponents()
    components.day = 1
    return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
  }
}
