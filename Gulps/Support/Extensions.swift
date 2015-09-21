import Foundation

extension NSUserDefaults {
    class func groupUserDefaults() -> NSUserDefaults {
        return NSUserDefaults(suiteName: "group.\(Constants.bundle())")!
    }
}

extension Double {
    func formattedPercentage() -> String {
        let percentageFormatter = NSNumberFormatter()
        percentageFormatter.numberStyle = .PercentStyle
        return percentageFormatter.stringFromNumber(round(self) / 100.0) ?? "\(self)%"
    }
}
