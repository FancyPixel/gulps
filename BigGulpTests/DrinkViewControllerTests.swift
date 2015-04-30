import UIKit
import Quick
import Nimble
import Nimble_Snapshots

import Gulps

class MockEntryHandler: EntryHandler {
    let entry = Entry()
    override func currentEntry() -> Entry {
        return entry
    }

    override func addGulp(quantity: Double) {
        entry.percentage = quantity
        println(entry.percentage)
    }
}

class MockUserDefaults: NSUserDefaults {
    override func doubleForKey(defaultName: String) -> Double {
        if (defaultName == Settings.Gulp.Small.key()) {
            return 10
        } else {
            return 20
        }
    }

    override func boolForKey(defaultName: String) -> Bool {
        return true
    }
}

class DrinkViewControllerSpecs: QuickSpec {
    override func spec() {
        var subject: DrinkViewController!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let tabBarController = storyboard.instantiateInitialViewController() as! UITabBarController
            let navigationController = tabBarController.viewControllers![0] as! UINavigationController
            subject = navigationController.topViewController as! DrinkViewController
            subject.entryHandler = MockEntryHandler()
            subject.userDefaults = MockUserDefaults()
            UIApplication.sharedApplication().keyWindow!.rootViewController = tabBarController
            NSRunLoop.mainRunLoop().runUntilDate(NSDate())
            subject.percentageLabel.animationDuration = 0.1 // makes testing easier
        }

        describe("when the controller loads") {
            it("should display the starting progress as 0%") {
                expect(subject.percentageLabel.text).to(equal("0%"))
                expect(subject.progressMeter.progress).to(equal(0))
            }

            it("should present an empty meter") {
                expect(subject.progressMeter).to(haveValidSnapshot())
            }
        }

        describe("when a small gulp is added") {
            it("should update the progress") {
                subject.selectionButtonAction(subject.smallButton)
                expect(subject.percentageLabel.text).toEventually(equal("10%"))
                expect(subject.progressMeter).toEventually(haveValidSnapshot())
            }
        }

        describe("when a big gulp is added") {
            it("should update the progress label") {
                subject.selectionButtonAction(subject.largeButton)
                expect(subject.percentageLabel.text).toEventually(equal("20%"))
                expect(subject.progressMeter).toEventually(haveValidSnapshot())
            }
        }
    }
}
