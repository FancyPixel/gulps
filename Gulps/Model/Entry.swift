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

    class func entryForToday() -> Entry? {
        return entryForDate(NSDate())
    }

    class func entryForDate(date: NSDate) -> Entry? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let p: NSPredicate = NSPredicate(format: "date = %@", argumentArray: [ dateFormat.stringFromDate(date) ])
        let objects = Realm().objects(Entry).filter(p)
        return objects.first
    }

    func addGulp(quantity: Double, goal: Double) {
        let gulp = Gulp()
        gulp.quantity = quantity
        self.gulps.append(gulp)
        self.quantity += quantity
        self.goal = goal
        self.percentage = self.quantity / self.goal * 100.0
        if (self.percentage > 100) {
            self.percentage = 100
        }
    }

    func removeLastGulp() {
        if let gulp = self.gulps.last {
            self.quantity -= gulp.quantity
            self.percentage = self.quantity / self.goal * 100.0
            if (self.percentage < 0) {
                self.percentage = 0
            }
            if (self.percentage > 100) {
                self.percentage = 100
            }
            self.gulps.removeLast()
        }
    }

    func formattedPercentage() -> String {
        let percentageFormatter = NSNumberFormatter()
        percentageFormatter.numberStyle = .PercentStyle
        return percentageFormatter.stringFromNumber(round(percentage) / 100.0) ?? "\(percentage)%"
    }
}
