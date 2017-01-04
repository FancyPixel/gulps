import UIKit

typealias Palette = UIColor
extension Palette {
  class var palette_main: UIColor {
    return UIColor(red:0.22, green:0.49, blue:0.81, alpha:1)
  }

  class var palette_yellow: UIColor {
    return UIColor(red: 245.0/255.0, green: 192.0/255.0, blue: 24.0/255.0, alpha: 1)
  }

  class var palette_confirm: UIColor {
    return UIColor(red:0.6, green:0.8, blue:0.37, alpha:1)
  }

  class var palette_destructive: UIColor {
    return UIColor(red:0.75, green:0.22, blue:0.17, alpha:1)
  }

  class var palette_lightGray: UIColor {
    return UIColor(red:0.91, green:0.91, blue:0.92, alpha:1)
  }
}
