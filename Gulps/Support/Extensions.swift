import Foundation
import UIKit

extension UserDefaults {
  class func groupUserDefaults() -> UserDefaults {
    return UserDefaults(suiteName: "group.\(Constants.bundle())")!
  }
}

extension Double {
  func formattedPercentage() -> String {
    let value = self.rounded()
    let percentageFormatter = NumberFormatter()
    percentageFormatter.numberStyle = .percent
    return percentageFormatter.string(for: value / 100.0) ?? "\(self)%"
  }
}

extension NSRange {
  func toRange(_ string: String) -> Range<String.Index> {
    let startIndex = string.characters.index(string.startIndex, offsetBy: location)
    let endIndex = string.characters.index(startIndex, offsetBy: length)
    return startIndex..<endIndex
  }
}

extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }

  var startOfTomorrow: Date? {
    var components = DateComponents()
    components.day = 1
    return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
  }
}
