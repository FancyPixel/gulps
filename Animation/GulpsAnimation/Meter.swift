import UIKit

class MeterShape {
    class func path() -> CGPath {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(151.54, 0.11))
        bezierPath.addCurveToPoint(CGPointMake(128.01, 280), controlPoint1: CGPointMake(149.78, -6.36), controlPoint2: CGPointMake(-97.92, 280))
        bezierPath.addCurveToPoint(CGPointMake(161.91, 55.97), controlPoint1: CGPointMake(353.94, 280), controlPoint2: CGPointMake(218.31, 78.08))
        bezierPath.addCurveToPoint(CGPointMake(128.01, 261.46), controlPoint1: CGPointMake(161.91, 55.97), controlPoint2: CGPointMake(333.83, 261.46))
        bezierPath.addCurveToPoint(CGPointMake(151.54, 0.11), controlPoint1: CGPointMake(-43.49, 261.46), controlPoint2: CGPointMake(153.52, 10.34))
        bezierPath.closePath()

        return bezierPath.CGPath
    }
}
