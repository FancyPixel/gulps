import UIKit
import AHKActionSheet
import AMPopTip

class Globals {
  class func numericToolbar(_ target: AnyObject?, selector: Selector, barColor: UIColor = UIColor.white, textColor: UIColor = UIColor.palette_main) -> UIToolbar {
    let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
    numberToolbar.barStyle = .blackTranslucent

    let button = UIBarButtonItem(title: "Ok", style: .done, target: target, action: selector)
    if let font = UIFont(name: "Avenir-Book", size: 16) {
      button.setTitleTextAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: textColor], for: UIControlState())
    }
    numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), button]
    numberToolbar.sizeToFit()
    numberToolbar.isTranslucent = true
    numberToolbar.tintColor = textColor
    numberToolbar.barTintColor = barColor

    return numberToolbar
  }

  class func actionSheetAppearance() {
    AHKActionSheet.appearance().separatorColor = UIColor(white: 1, alpha: 0.3)
    AHKActionSheet.appearance().blurTintColor = .palette_main
    if let font = UIFont(name: "Avenir-Book", size: 16) {
      AHKActionSheet.appearance().buttonTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
      AHKActionSheet.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
      AHKActionSheet.appearance().buttonTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
      AHKActionSheet.appearance().cancelButtonTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font]
    }
  }

  class func numericTextField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else {
      return false
    }
    let newValue = text.replacingCharacters(in: range.toRange(text), with: string)
    if (newValue.characters.count == 0) {
      return true;
    }
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter.number(from: newValue) != nil
  }

  class func showPopTipOnceForKey(_ key: String, userDefaults: UserDefaults, popTipText text: String, inView view: UIView, fromFrame frame: CGRect, direction: AMPopTipDirection = .down, color: UIColor = .palette_main) {
    if (!userDefaults.bool(forKey: key)) {
      userDefaults.set(true, forKey: key)
      userDefaults.synchronize()
      AMPopTip.appearance().popoverColor = color
      AMPopTip.appearance().offset = 10
      AMPopTip.appearance().edgeMargin = 5
      let popTip = AMPopTip()
      popTip.showText(text, direction: direction, maxWidth: 200, in: view, fromFrame: frame)
    }
  }
}
