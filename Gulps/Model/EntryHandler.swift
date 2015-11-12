import Foundation
import RealmSwift

/**
Helper singleton to perform operations on the Realm database
*/
public class EntryHandler: NSObject {

    public static let sharedHandler = EntryHandler()
    public lazy var userDefaults = NSUserDefaults.groupUserDefaults()

    /**
    Realm is initialized lazily, using the group bundle identifier.
    */
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

    /**
    Returns the current entry
    - returns: Entry?
    */
    public func entryForToday() -> Entry? {
        return entryForDate(NSDate())
    }

    /**
    Returns an entry for the given date
    - parameter date: The desired date
    - returns: Entry?
    */
    public func entryForDate(date: NSDate) -> Entry? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let p: NSPredicate = NSPredicate(format: "date = %@", argumentArray: [ dateFormat.stringFromDate(date) ])
        let objects = realm.objects(Entry).filter(p)
        return objects.first
    }

    /**
    Returns the current entry if available, or creates a new one instead
    - returns: Entry
    */
    public func currentEntry() -> Entry {
        if let entry = entryForToday() {
            return entry
        } else {
            let newEntry = Entry()
            try! realm.write {
                self.realm.add(newEntry, update: true)
            }
            return newEntry
        }
    }

    /**
    Gets the current percentage
    - returns: Double
    */
    public func currentPercentage() -> Double {
        return currentEntry().percentage
    }

    /**
    Adds a portion to the current entry. If available, the sample is saved in HealthKit as well
    - parameter quantity: The sample value
    */
    public func addGulp(quantity: Double) {
        addGulp(quantity, date: nil)
    }

    /**
     Adds a portion to the current entry for a given date. If available, the sample is saved in HealthKit as well
     - parameter quantity: The sample value
     - parameter date: The sample date
     */
    public func addGulp(quantity: Double, date: NSDate?) {
        if #available(iOS 9.0, *) {
            HealthKitHelper.sharedHelper.saveSample(quantity)
        }
        let entry = currentEntry()
        try! realm.write {
            entry.addGulp(quantity, goal: self.userDefaults.doubleForKey(Constants.Gulp.Goal.key()), date: date)
        }
    }

    /**
    Removes the last portion to the current entry. If available, the sample is removed in HealthKit as well
    */
    public func removeLastGulp() {
        if #available(iOS 9.0, *) {
            HealthKitHelper.sharedHelper.removeLastSample()
        }
        let entry = currentEntry()
        if let gulp = entry.gulps.last {
            try! realm.write {
                entry.removeLastGulp()
                self.realm.delete(gulp)
            }
        }
    }

    /**
    Returns the value of all the portions recorded
    - returns: Double
    */
    public func overallQuantity() -> Double {
        return realm.objects(Entry).sum("quantity") as Double
    }

    /**
    Returns the value number of days tracked
    - returns: Int
    */
    public func daysTracked() -> Int {
        return realm.objects(Entry).count
    }
}
