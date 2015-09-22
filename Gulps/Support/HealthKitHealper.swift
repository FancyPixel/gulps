import Foundation
import HealthKit

public class HealthKitHelper {
    static let sharedHelper = HealthKitHelper()
    let healthKitStore = HKHealthStore()

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
}
