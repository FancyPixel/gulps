import Foundation
import RealmSwift

public class EntryHandler: NSObject {

    public static let sharedHandler = EntryHandler()
    public lazy var userDefaults = NSUserDefaults.groupUserDefaults()

    public lazy var realm: Realm = {
        if let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(Constants.bundle())") {
            let realmPath = directory.path!.stringByAppendingPathComponent("db.realm")
            Realm.defaultPath = realmPath
        } else {
            assertionFailure("Unable to setup Realm. Make sure to setup your app group in the developer portal")
        }
        return Realm()
    }()

    public func entryForToday() -> Entry? {
        return entryForDate(NSDate())
    }

    public func entryForDate(date: NSDate) -> Entry? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let p: NSPredicate = NSPredicate(format: "date = %@", argumentArray: [ dateFormat.stringFromDate(date) ])
        let objects = realm.objects(Entry).filter(p)
        return objects.first
    }

    public func currentEntry() -> Entry {
        if let entry = entryForToday() {
            return entry
        } else {
            let newEntry = Entry()
            realm.write {
                self.realm.add(newEntry, update: true)
            }
            return newEntry
        }
    }

    public func currentPercentage() -> Double {
        return currentEntry().percentage
    }

    public func addGulp(quantity: Double) {
        let entry = currentEntry()
        realm.write {
            entry.addGulp(quantity, goal: self.userDefaults.doubleForKey(Settings.Gulp.Goal.key()))
        }
    }

    public func removeLastGulp() {
        let entry = currentEntry()
        if let gulp = entry.gulps.last {
            realm.write {
                entry.removeLastGulp()
                self.realm.delete(gulp)
            }
        }
    }

    public func overallQuantity() -> Double {
        return realm.objects(Entry).sum("quantity") as Double
    }

    public func daysTracked() -> Int {
        return realm.objects(Entry).count
    }
}
