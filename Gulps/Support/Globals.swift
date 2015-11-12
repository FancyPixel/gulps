import UIKit
import AHKActionSheet
import AMPopTip

class Globals {
    class func numericToolbar(target: AnyObject, selector: Selector, barColor: UIColor = UIColor.whiteColor(), textColor: UIColor = UIColor.mainColor()) -> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        numberToolbar.barStyle = .BlackTranslucent

        let button = UIBarButtonItem(title: "Ok", style: .Done, target: target, action: selector)
        if let font = UIFont(name: "Avenir-Book", size: 16) {
            button.setTitleTextAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: textColor], forState: UIControlState.Normal)
        }
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), button]
        numberToolbar.sizeToFit()
        numberToolbar.translucent = true
        numberToolbar.tintColor = textColor
        numberToolbar.barTintColor = barColor

        return numberToolbar
    }

    class func actionSheetAppearance() {
        AHKActionSheet.appearance().separatorColor = UIColor(white: 1, alpha: 0.3)
        AHKActionSheet.appearance().blurTintColor = UIColor.mainColor()
        if let font = UIFont(name: "Avenir-Book", size: 16) {
            AHKActionSheet.appearance().buttonTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font]
            AHKActionSheet.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font]
            AHKActionSheet.appearance().buttonTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font]
            AHKActionSheet.appearance().cancelButtonTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font]
        }
    }

    class func numericTextField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let newValue = text.stringByReplacingCharactersInRange(range.toRange(text), withString: string)
        if (newValue.characters.count == 0) {
            return true;
        }
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter.numberFromString(newValue) != nil
    }

    class func showPopTipOnceForKey(key: String, userDefaults: NSUserDefaults, popTipText text: String, inView view: UIView, fromFrame frame: CGRect, direction: AMPopTipDirection = .Down, color: UIColor = .mainColor()) {
        if (!userDefaults.boolForKey(key)) {
            userDefaults.setBool(true, forKey: key)
            userDefaults.synchronize()
            AMPopTip.appearance().popoverColor = color
            AMPopTip.appearance().offset = 10
            AMPopTip.appearance().edgeMargin = 5
            let popTip = AMPopTip()
            popTip.showText(text, direction: direction, maxWidth: 200, inView: view, fromFrame: frame)
        }
    }
}
