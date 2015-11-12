import Foundation
import RealmSwift

/**
Represents the single portion. Multiple portions will be recorded throughout the day (Entry)
*/
public class Gulp: Object {
    dynamic var date = NSDate()
    dynamic var quantity = 0.0

    public convenience init(quantity: Double) {
        self.init()
        self.quantity = quantity
    }
}
