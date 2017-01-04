import UIKit
import Quick
import Nimble
import Nimble_Snapshots

import RealmSwift

import Gulps

class MockUserDefaults: UserDefaults {
  override func double(forKey defaultName: String) -> Double {
    switch defaultName {
    case Constants.Gulp.small.key():
      return 0.1
    case Constants.Gulp.big.key():
      return 0.2
    case Constants.Gulp.goal.key():
      return 1
    default:
      return 0
    }
  }

  override func bool(forKey defaultName: String) -> Bool {
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
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let tabBarController = storyboard.instantiateInitialViewController() as! UITabBarController
      let navigationController = tabBarController.viewControllers![0] as! UINavigationController
      subject = navigationController.topViewController as! DrinkViewController
      subject.userDefaults = MockUserDefaults()
      UIApplication.shared.keyWindow!.rootViewController = tabBarController
      RunLoop.main.run(until: Date())
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
