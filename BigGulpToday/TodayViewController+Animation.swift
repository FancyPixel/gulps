//
//  TodayViewController+Animation.swift
//  BigGulp
//
//  Created by Andrea Mazzini on 21/03/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import UIKit
import pop

extension TodayViewController {
    func showConfirmButtons() {
        let scaleDownBig = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDownBig.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDownBig.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDownBig.removedOnCompletion = true
        scaleDownBig.duration = 0.2
        scaleDownBig.completionBlock = { (_, _) in
            let scaleUpBig = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            scaleUpBig.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
            scaleUpBig.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            scaleUpBig.removedOnCompletion = true
            scaleUpBig.duration = 0.2
            self.bigConfirmButton.pop_addAnimation(scaleUpBig, forKey: "scaleUpBig")
        };
        self.bigGulpButton.pop_addAnimation(scaleDownBig, forKey: "scaleDownBig")
        
        let scaleDownSmall = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDownSmall.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDownSmall.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDownSmall.removedOnCompletion = true
        scaleDownSmall.duration = 0.2
        scaleDownSmall.completionBlock = { (_, _) in
            let scaleUpSmall = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            scaleUpSmall.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
            scaleUpSmall.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            scaleUpSmall.removedOnCompletion = true
            scaleUpSmall.duration = 0.2
            self.smallConfirmButton.pop_addAnimation(scaleUpSmall, forKey: "scaleUpSmall")
        };
        self.smallGulpButton.pop_addAnimation(scaleDownSmall, forKey: "scaleDownSmall")
    }
    
    func hideConfirmButtons() {
        let scaleDownBig = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDownBig.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDownBig.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDownBig.removedOnCompletion = true
        scaleDownBig.duration = 0.2
        scaleDownBig.completionBlock = { (_, _) in
            let scaleUpBig = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            scaleUpBig.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
            scaleUpBig.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            scaleUpBig.removedOnCompletion = true
            scaleUpBig.duration = 0.2
            self.bigGulpButton.pop_addAnimation(scaleUpBig, forKey: "scaleUpBig")
        };
        self.bigConfirmButton.pop_addAnimation(scaleDownBig, forKey: "scaleDownBig")
        
        let scaleDownSmall = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleDownSmall.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleDownSmall.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleDownSmall.removedOnCompletion = true
        scaleDownSmall.duration = 0.2
        scaleDownSmall.completionBlock = { (_, _) in
            let scaleUpSmall = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            scaleUpSmall.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
            scaleUpSmall.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            scaleUpSmall.removedOnCompletion = true
            scaleUpSmall.duration = 0.2
            self.smallGulpButton.pop_addAnimation(scaleUpSmall, forKey: "scaleUpSmall")
        };
        self.smallConfirmButton.pop_addAnimation(scaleDownSmall, forKey: "scaleDownSmall")
    }
}
