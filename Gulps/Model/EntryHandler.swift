import Foundation
import RealmSwift

public class EntryHandler: NSObject {

    static let sharedHandler = EntryHandler()

    lazy var realm: Realm = {
        if let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(Constants.bundle())") {
            let realmPath = directory.path!.stringByAppendingPathComponent("db.realm")
            Realm.defaultPath = realmPath
        } else {
            assertionFailure("Unable to setup Realm. Make sure to setup your app group in the developer portal")
        }
        return Realm()
    }()

    public func currentEntry() -> Entry {
        if let entry = Entry.entryForToday() {
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
            entry.addGulp(quantity, goal: NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Goal.key()))
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
