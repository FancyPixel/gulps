import Foundation
import RealmSwift

public class EntryHandler: NSObject {

    public class func bootstrapRealm() {
        if let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(Constants.bundle())") {
            let realmPath = directory.path!.stringByAppendingPathComponent("db.realm")
            Realm.defaultPath = realmPath
        } else {
            assertionFailure("Unable to setup Realm. Make sure to setup your app group in the developer portal")
        }
    }

    public func currentEntry() -> Entry {
        if let entry = Entry.entryForToday() {
            return entry
        } else {
            let newEntry = Entry()
            let realm = Realm()
            realm.write {
                realm.add(newEntry, update: true)
            }
            return newEntry
        }
    }

    public func addGulp(quantity: Double) {
        let entry = currentEntry()
        Realm().write {
            entry.addGulp(quantity, goal: NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Goal.key()))
        }
    }

    public func removeLastGulp() {
        let realm = Realm()
        let entry = currentEntry()
        if let gulp = entry.gulps.last {
            realm.write {
                entry.removeLastGulp()
                realm.delete(gulp)
            }
        }
    }

    public class func overallQuantity() -> Double {
        return Realm().objects(Entry).sum("quantity") as Double
    }

    public class func daysTracked() -> Int {
        return Realm().objects(Entry).count
    }
}
