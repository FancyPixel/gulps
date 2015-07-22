import Foundation
import RealmSwift

public class Gulp: Object {
    dynamic var date = NSDate()
    dynamic var quantity = 0.0

    public convenience init(quantity: Double) {
        self.init()
        self.quantity = quantity
    }
}
