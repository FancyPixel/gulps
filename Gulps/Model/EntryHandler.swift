import Foundation
import Realm

public class EntryHandler: NSObject {

    public class func bootstrapRealm() {
        if let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(Constants.bundle())") {
            let realmPath = directory.path!.stringByAppendingPathComponent("db.realm")
            RLMRealm.setDefaultRealmPath(realmPath)
        } else {
            assertionFailure("Unable to setup Realm. Make sure to setup your app group in the developer portal")
        }
    }

    public func currentEntry() -> Entry {
        if let entry = Entry.entryForToday() {
            return entry
        } else {
            let newEntry = Entry()
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            newEntry.percentage = 0
            newEntry.quantity = 0
            realm.addObject(newEntry)
            realm.commitWriteTransaction()
            return newEntry
        }
    }

    public func addGulp(quantity: Double) {
        let entry = currentEntry()
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        entry.addGulp(quantity, goal: NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Goal.key()))
        realm.commitWriteTransaction()
    }

    public func removeLastGulp() {
        let realm = RLMRealm.defaultRealm()
        let entry = currentEntry()
        if let gulp = entry.gulps.lastObject() as? Gulp {
            realm.beginWriteTransaction()
            entry.removeLastGulp()
            realm.deleteObject(gulp)
            realm.commitWriteTransaction()
        }
    }

    public class func overallQuantity() -> Double {
        return Entry.allObjects().sumOfProperty("quantity") as Double
    }

    public class func daysTracked() -> UInt {
        return Entry.allObjects().count as UInt
    }
}
