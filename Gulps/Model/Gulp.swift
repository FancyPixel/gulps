import Foundation
import RealmSwift

/// Represents the single portion. Multiple portions will be recorded throughout the day 
/// - SeeAlso: `Entry`
open class Gulp: Object {
  dynamic var date = Date()
  dynamic var quantity = 0.0

  public convenience init(quantity: Double) {
    self.init()
    self.quantity = quantity
  }
}
