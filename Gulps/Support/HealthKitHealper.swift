import Foundation
import HealthKit

/**
 HealthKit Helper
 Handles the insertion and deletion of items in HealthKit
 */
open class HealthKitHelper {
  static let sharedHelper = HealthKitHelper()
  let healthKitStore = HKHealthStore()

  /**
   Ask permission to share data with HealthKit
   */
  @available(iOS 9.0, *)
  func askPermission() {
    let types = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!)

    if !HKHealthStore.isHealthDataAvailable() {
      return;
    }

    healthKitStore.requestAuthorization(toShare: types, read: nil) {
      (success, error) in
      if !success {
        print(error)
      }
    }
  }

  /**
   Save a sample, given the value.
   The unit of measure is retrieved from the NSUserDefaults
   - Parameter value: The sample value
   */
  @available(iOS 9.0, *)
  func saveSample(_ value: Double) {
    if !UserDefaults.groupUserDefaults().bool(forKey: Constants.Health.on.key()) {
      return
    }

    if !HKHealthStore.isHealthDataAvailable() || healthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!) != HKAuthorizationStatus.sharingAuthorized {
      return;
    }

    guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
      return
    }

    let unit = Constants.UnitsOfMeasure(rawValue: UserDefaults.groupUserDefaults().integer(forKey: Constants.General.unitOfMeasure.key()))
    var quantity = HKQuantity(unit: HKUnit.liter(), doubleValue: value)
    if (unit == Constants.UnitsOfMeasure.ounces) {
      quantity = HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: value)
    }
    let sample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
    healthKitStore.save(sample, withCompletion: {
      (success, error) in
      if let error = error {
        print("Error saving sample: \(error.localizedDescription)")
      }
    }) 
  }

  /**
   Remove the last sample
   */
  @available(iOS 9.0, *)
  func removeLastSample() {
    if !UserDefaults.groupUserDefaults().bool(forKey: Constants.Health.on.key()) {
      return
    }

    if !HKHealthStore.isHealthDataAvailable() || healthKitStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!) != HKAuthorizationStatus.sharingAuthorized {
      return;
    }

    guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
      return
    }

    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) {
      [unowned self] (query, results, error) in
      if let results = results as? [HKQuantitySample], let sample = results.first {
        self.healthKitStore.delete(sample, withCompletion: {
          (success, error) in
          if let error = error {
            print(error)
          }
        }) 
      }
    }

    healthKitStore.execute(query)
  }

}
