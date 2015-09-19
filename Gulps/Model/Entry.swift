import Foundation
import RealmSwift

public class Entry: Object {
    dynamic public var date = Entry.defaultDate()
    dynamic public var quantity = 0.0
    dynamic public var percentage = 0.0
    dynamic public var goal = 0.0
    public let gulps = List<Gulp>()

    class func defaultDate() -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.stringFromDate(NSDate())
    }

    override public class func primaryKey() -> String {
        return "date"
    }

    func addGulp(quantity: Double, goal: Double) {
        let gulp = Gulp(quantity: quantity)
        self.gulps.append(gulp)
        self.quantity += quantity
        self.goal = goal
        if goal > 0 {
            self.percentage = (self.quantity / self.goal) * 100.0
        }
    }

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

    func formattedPercentage() -> String {
        return percentage.formattedPercentage()
    }
}
