import UIKit

class ProgressMeter {
    class func pathFromRect(rect: CGRect) -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(rect.size.width / 2, 0))
        bezierPath.addCurveToPoint(CGPointMake(rect.size.width / 2, rect.size.height),
            controlPoint1: CGPointMake(rect.size.width / 2, 0),
            controlPoint2: CGPointMake(-0.3 * rect.size.width, rect.size.height)
        )
        bezierPath.addCurveToPoint(CGPointMake(rect.size.width / 2, 0),
            controlPoint1: CGPointMake(1.3 * rect.size.width, rect.size.height),
            controlPoint2: CGPointMake(rect.size.width / 2, 0)
        )

        return bezierPath.CGPath
    }
}
