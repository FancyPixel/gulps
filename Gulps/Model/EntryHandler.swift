import Foundation
import RealmSwift

public class EntryHandler: NSObject {

    public static let sharedHandler = EntryHandler()
    public lazy var userDefaults = NSUserDefaults.groupUserDefaults()

    public lazy var realm: Realm = {
        guard let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(Constants.bundle())") else {
            fatalError("Unable to setup Realm. Make sure to setup your app group in the developer portal")
        }

        let realmPath = directory.URLByAppendingPathComponent("db.realm")
        var config = Realm.Configuration()
        config.path = realmPath.path
        Realm.Configuration.defaultConfiguration = config

        return try! Realm()
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
        if #available(iOS 9.0, *) {
            HealthKitHelper.sharedHelper.saveSample(quantity)
        }
        let entry = currentEntry()
        realm.write {
            entry.addGulp(quantity, goal: self.userDefaults.doubleForKey(Constants.Gulp.Goal.key()))
        }
    }

    public func removeLastGulp() {
        if #available(iOS 9.0, *) {
            HealthKitHelper.sharedHelper.removeLastSample()
        }
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
