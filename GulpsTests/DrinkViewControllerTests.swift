import UIKit
import Quick
import Nimble
import Nimble_Snapshots

import RealmSwift

import Gulps

class MockUserDefaults: NSUserDefaults {
    override func doubleForKey(defaultName: String) -> Double {
        switch defaultName {
        case Constants.Gulp.Small.key():
            return 0.1
        case Constants.Gulp.Big.key():
            return 0.2
        case Constants.Gulp.Goal.key():
            return 1
        default:
            return 0
        }
        
        // NOTE: The "Constants.Gulp.Custom.key" does not require a mock value.
        // It is set by the user each time they enter a custom value, and it's
        // not possible to set a custom value from anywhere else in the app.
    }

    override func boolForKey(defaultName: String) -> Bool {
        return true
    }
}

class DrinkViewControllerSpecs: QuickSpec {
    override func spec() {
        var subject: DrinkViewController!
        beforeSuite {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = "gulps-spec"
            Realm.Configuration.defaultConfiguration = config
            EntryHandler.sharedHandler.realm = try! Realm()
            EntryHandler.sharedHandler.userDefaults = MockUserDefaults()
        }

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let tabBarController = storyboard.instantiateInitialViewController() as! UITabBarController
            let navigationController = tabBarController.viewControllers![0] as! UINavigationController
            subject = navigationController.topViewController as! DrinkViewController
            subject.userDefaults = MockUserDefaults()
            UIApplication.sharedApplication().keyWindow!.rootViewController = tabBarController
            NSRunLoop.mainRunLoop().runUntilDate(NSDate()) 
            subject.percentageLabel.animationDuration = 0.1 // makes testing easier
        }

        afterEach {
            try! EntryHandler.sharedHandler.realm.write {
                EntryHandler.sharedHandler.realm.deleteAll()
            }
        }

        describe("when the controller loads") {
            it("should display the starting progress as 0%") {
                expect(subject.percentageLabel.text).to(equal("0%"))
            }
        }

        describe("when a small gulp is added") {
            it("should update the progress") {
                subject.selectionButtonAction(subject.smallButton)
                expect(subject.percentageLabel.text).toEventually(equal("10%"))
            }
        }

        describe("when a big gulp is added") {
            it("should update the progress label") {
                subject.selectionButtonAction(subject.largeButton)
                expect(subject.percentageLabel.text).toEventually(equal("20%"))
            }
        }
    }
}
