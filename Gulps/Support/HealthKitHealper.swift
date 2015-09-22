import Foundation
import HealthKit

/**
HealthKit Helper
Handles the insertion and deletion of items in HealthKit
*/
public class HealthKitHelper {
    static let sharedHelper = HealthKitHelper()
    let healthKitStore = HKHealthStore()

    /** 
    Ask permission to share data with HealthKit
    */
    @available(iOS 9.0, *)
    func askPermission() {
        let types = Set(arrayLiteral: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!)

        if !HKHealthStore.isHealthDataAvailable() {
            return;
        }

        healthKitStore.requestAuthorizationToShareTypes(types, readTypes: nil) {
            (success, error) in
            if !success {
                print(error)
            }
        }
    }

    @available(iOS 9.0, *)
    func saveSample(value: Double) {
        if !NSUserDefaults.groupUserDefaults().boolForKey(Constants.Health.On.key()) {
            return
        }

        if !HKHealthStore.isHealthDataAvailable() || healthKitStore.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!) != HKAuthorizationStatus.SharingAuthorized {
            return;
        }

        guard let type = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) else {
            return
        }

        let unit = Constants.UnitsOfMeasure(rawValue: NSUserDefaults.groupUserDefaults().integerForKey(Constants.General.UnitOfMeasure.key()))
        var quantity = HKQuantity(unit: HKUnit.literUnit(), doubleValue: value)
        if (unit == Constants.UnitsOfMeasure.Ounces) {
            quantity = HKQuantity(unit: HKUnit.fluidOunceUSUnit(), doubleValue: value)
        }
        let sample = HKQuantitySample(type: type, quantity: quantity, startDate: NSDate(), endDate: NSDate())
        healthKitStore.saveObject(sample) {
            (success, error) in
            if let error = error {
                print("Error saving sample: \(error.localizedDescription)")
            }
        }
    }

    @available(iOS 9.0, *)
    func removeLastSample() {
        if !NSUserDefaults.groupUserDefaults().boolForKey(Constants.Health.On.key()) {
            return
        }

        if !HKHealthStore.isHealthDataAvailable() || healthKitStore.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!) != HKAuthorizationStatus.SharingAuthorized {
            return;
        }

        guard let type = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) else {
            return
        }

        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) {
            [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample], let sample = results.first {
                self.healthKitStore.deleteObject(sample) {
                    (success, error) in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }

        healthKitStore.executeQuery(query)
    }

}
