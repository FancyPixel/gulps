import Foundation
import RealmSwift

/**
 Helper singleton to perform operations on the Realm database
 */
open class EntryHandler: NSObject {

  open static let sharedHandler = EntryHandler()
  open lazy var userDefaults = UserDefaults.groupUserDefaults()

  /**
   Realm is initialized lazily, using the group bundle identifier.
   */
  open lazy var realm: Realm = {
    guard let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Constants.bundle())") else {
      fatalError("Unable to setup Realm. Make sure to setup your app group in the developer portal")
    }

    let realmPath = directory.appendingPathComponent("db.realm")
    var config = Realm.Configuration()
    config.fileURL = realmPath
    Realm.Configuration.defaultConfiguration = config

    return try! Realm()
  }()

  /**
   Returns the current entry
   - returns: Entry?
   */
  open func entryForToday() -> Entry? {
    return entryForDate(Date())
  }

  /**
   Returns an entry for the given date
   - parameter date: The desired date
   - returns: Entry?
   */
  open func entryForDate(_ date: Date) -> Entry? {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    let p: NSPredicate = NSPredicate(format: "date = %@", argumentArray: [ dateFormat.string(from: date) ])
    let objects = realm.objects(Entry.self).filter(p)
    return objects.first
  }

  open func createEntryForDate(_ date: Date) -> Entry {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    let newEntry = Entry()
    newEntry.date = dateFormat.string(from: date)
    try! realm.write {
      self.realm.add(newEntry, update: true)
    }
    return newEntry
  }

  /**
   Returns the current entry if available, or creates a new one instead
   - returns: Entry
   */
  open func currentEntry() -> Entry {
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
  open func currentPercentage() -> Double {
    return currentEntry().percentage
  }

  /**
   Adds a portion to the current entry. If available, the sample is saved in HealthKit as well
   - parameter quantity: The sample value
   */
  open func addGulp(_ quantity: Double) {
    addGulp(quantity, date: nil)
  }

  /**
   Adds a portion to the current entry for a given date. If available, the sample is saved in HealthKit as well
   - parameter quantity: The sample value
   - parameter date: The sample date
   */
  open func addGulp(_ quantity: Double, date: Date?) {
    HealthKitHelper.sharedHelper.saveSample(quantity, date: date)
    var entry: Entry?
    if let date = date {
      entry = entryForDate(date)
      if entry == nil {
        entry = createEntryForDate(date)
      }
    } else {
      entry = currentEntry()
    }
    try! realm.write {
      entry?.addGulp(quantity, goal: self.userDefaults.double(forKey: Constants.Gulp.goal.key()), date: date)
    }
  }

  /**
   Removes the last portion to the current entry. If available, the sample is removed in HealthKit as well
   */
  open func removeLastGulp() {
    HealthKitHelper.sharedHelper.removeLastSample()
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
  open func overallQuantity() -> Double {
    return realm.objects(Entry.self).sum(ofProperty: "quantity") as Double
  }

  /**
   Returns the value number of days tracked
   - returns: Int
   */
  open func daysTracked() -> Int {
    return realm.objects(Entry.self).count
  }
}
