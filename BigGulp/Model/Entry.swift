import Foundation

class Entry: RLMObject {
    dynamic var date = Entry.defaultDate()
    dynamic var quantity = 0.0
    dynamic var percentage = 0.0
    dynamic var goal = 0.0
    dynamic var gulps = RLMArray(objectClassName: Gulp.className())

    class func defaultDate() -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.stringFromDate(NSDate())
    }

    override class func primaryKey() -> String {
        return "date"
    }

    class func entryForToday() -> Entry? {
        return entryForDate(NSDate())
    }

    class func entryForDate(date: NSDate) -> Entry? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let p : NSPredicate = NSPredicate(format: "date = %@", argumentArray: [ dateFormat.stringFromDate(date) ])
        let objects = Entry.objectsWithPredicate(p)
        return objects.firstObject() as? Entry
    }

    func addGulp(quantity: Double, goal: Double, realm: RLMRealm) {
        realm.beginWriteTransaction()
        let gulp = Gulp()
        gulp.quantity = quantity
        self.gulps.addObject(gulp)
        self.quantity += quantity
        self.goal = goal
        self.percentage = self.quantity / self.goal * 100.0
        if (self.percentage > 100) {
            self.percentage = 100
        }
        realm.commitWriteTransaction()
    }

    func removeLastGulp(realm: RLMRealm) {
        realm.beginWriteTransaction()
        let gulp = self.gulps.lastObject() as! Gulp
        self.quantity -= gulp.quantity
        self.percentage = self.quantity / self.goal * 100.0
        if (self.percentage < 0) {
            self.percentage = 0
        }
        if (self.percentage > 100) {
            self.percentage = 100
        }
        self.gulps.removeLastObject()
        realm.commitWriteTransaction()
    }
}
