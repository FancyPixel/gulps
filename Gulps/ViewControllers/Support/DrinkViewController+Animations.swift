import pop

extension DrinkViewController {
    
    private var animationDistance: CGFloat {
        get {
            let maximumAnimationDistance: CGFloat = 100
            let padding: CGFloat = 16
            
            var animationDistance = maximumAnimationDistance
            
            if NSUserDefaults.groupUserDefaults().boolForKey(Constants.CustomGulp.On.key()) {
                // Calculate the animation distance allowing for the height of the custom button.
                let startPosition = bottomView.bounds.height - addButton.center.y
                let delta = bottomView.bounds.height - startPosition - padding - (customButton.bounds.height / 2)
                animationDistance = delta > maximumAnimationDistance ? maximumAnimationDistance : delta
                
                // NOTE: It is possible that the animation distance may be less than the height of the button. This
                // would cause the buttons to overlay each other, this would happen if the bottomView height is reduced.
                
            }
            
            return animationDistance

            // TODO: Prevent button over-lapping.
        }
    }

    func initAnimation() {
        smallButton.alpha = 0
        customButton.alpha = 0
        largeButton.alpha = 0
        starButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
    }

    func animateStarButton() {
        let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotate.toValue = 2 * M_PI - M_PI_4 / 2
        rotate.springBounciness = 5
        rotate.removedOnCompletion = true

        let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scale.toValue = NSValue(CGPoint: CGPointMake(0.8, 0.8))
        scale.removedOnCompletion = true
        scale.completionBlock = {(_,_) in
            let sway = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
            sway.fromValue = -M_PI_4 / 2
            sway.toValue = M_PI_4 / 2
            sway.duration = 0.75
            sway.repeatForever = true
            sway.autoreverses = true
            self.starButton.layer.pop_addAnimation(sway, forKey: "sway")
        }

        starButton.pop_addAnimation(scale, forKey: "scale")
        starButton.layer.pop_addAnimation(rotate, forKey: "rotate")
    }

    func expandAddButton() {
        addButton.userInteractionEnabled = false

        let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotate.fromValue = 0
        rotate.toValue = -M_PI + M_PI_4
        rotate.springBounciness = 5
        rotate.removedOnCompletion = true
        rotate.completionBlock = {(_, _) in
            self.addButton.userInteractionEnabled = true
            _ = [self.smallButton, self.customButton, self.largeButton].map({$0.userInteractionEnabled = true})
            self.expanded = true
        }

        let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scale.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scale.toValue = NSValue(CGPoint: CGPointMake(0.8, 0.8))
        scale.springBounciness = 5
        scale.removedOnCompletion = true

        let scaleMinus = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleMinus.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleMinus.toValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleMinus.removedOnCompletion = true

        let color = POPSpringAnimation(propertyNamed: kPOPViewBackgroundColor)
        color.fromValue = UIColor.mainColor()
        color.toValue = UIColor.destructiveColor()
        color.springBounciness = 5
        color.removedOnCompletion = true

        addButton.layer.pop_addAnimation(rotate, forKey: "rotate")
        addButton.pop_addAnimation(scale, forKey: "scale")
        addButton.pop_addAnimation(color, forKey: "color")
        minusButton.pop_addAnimation(scaleMinus, forKey: "scaleMinus")

        _ = [smallButton, customButton, largeButton].map({$0.alpha = 1})
        for button in [smallButton, customButton, largeButton] {
            let pop = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            pop.fromValue = NSValue(CGPoint: CGPointMake(0.1, 0.1))
            pop.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            pop.springBounciness = 5
            pop.removedOnCompletion = true
            button.pop_addAnimation(pop, forKey: "pop")
        }

        let left = POPSpringAnimation(propertyNamed: kPOPLayerTranslationX)
        left.springBounciness = 5
        left.fromValue = 0
        left.toValue = -animationDistance
        smallButton.layer.pop_addAnimation(left, forKey: "left")

        let right = POPSpringAnimation(propertyNamed: kPOPLayerTranslationX)
        right.springBounciness = 5
        right.fromValue = 0
        right.toValue = animationDistance
        largeButton.layer.pop_addAnimation(right, forKey: "right")
        
        let top = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
        top.springBounciness = 5
        top.fromValue = 0
        top.toValue = -animationDistance
        customButton.layer.pop_addAnimation(top, forKey: "top")
    }

    func contractAddButton() {
        _ = [smallButton, customButton, largeButton].map({$0.userInteractionEnabled = false})
        addButton.userInteractionEnabled = false

        let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotate.fromValue = -M_PI + M_PI_4
        rotate.toValue = 0
        rotate.springBounciness = 5

        rotate.completionBlock = {(_, _) in
            self.addButton.userInteractionEnabled = true
            self.expanded = false
        }

        let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scale.fromValue = NSValue(CGPoint: CGPointMake(0.8, 0.8))
        scale.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        scale.springBounciness = 5

        let color = POPSpringAnimation(propertyNamed: kPOPViewBackgroundColor)
        color.fromValue = UIColor.destructiveColor()
        color.toValue = UIColor.mainColor()
        color.springBounciness = 5

        let scaleMinus = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleMinus.fromValue = NSValue(CGPoint: CGPointMake(0, 0))
        scaleMinus.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        scaleMinus.removedOnCompletion = true

        addButton.layer.pop_addAnimation(rotate, forKey: "rotate")
        addButton.pop_addAnimation(scale, forKey: "scale")
        addButton.pop_addAnimation(color, forKey: "color")
        minusButton.pop_addAnimation(scaleMinus, forKey: "scaleMinus")

        for button in [smallButton, customButton, largeButton] {
            let pop = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            pop.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
            pop.toValue = NSValue(CGPoint: CGPointMake(0.1, 0.1))
            pop.springBounciness = 5
            pop.removedOnCompletion = true
            button.pop_addAnimation(pop, forKey: "pop")
        }

        let left = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
        left.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        left.fromValue = -animationDistance
        left.toValue = 0
        smallButton.layer.pop_addAnimation(left, forKey: "left")

        let right = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
        right.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        right.fromValue = animationDistance
        right.toValue = 0
        largeButton.layer.pop_addAnimation(right, forKey: "right")
        
        let top = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        top.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        top.fromValue = -animationDistance
        top.toValue = 0
        customButton.layer.pop_addAnimation(top, forKey: "top")
    }
}
