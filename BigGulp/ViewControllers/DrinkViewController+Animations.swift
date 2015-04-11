extension DrinkViewController {

    func initAnimation() {
        [self.smallButton, self.largeButton].map({$0.alpha = 0})
    }

    func expandAddButton() {
        self.addButton.userInteractionEnabled = false

        let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotate.fromValue = 0
        rotate.toValue = -M_PI + M_PI_4
        rotate.springBounciness = 5
        rotate.removedOnCompletion = true
        rotate.completionBlock = {(_, _) in
            self.addButton.userInteractionEnabled = true
            [self.smallButton, self.largeButton].map({$0.userInteractionEnabled = true})
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

        self.addButton.layer.pop_addAnimation(rotate, forKey: "rotate")
        self.addButton.pop_addAnimation(scale, forKey: "scale")
        self.addButton.pop_addAnimation(color, forKey: "color")
        self.minusButton.pop_addAnimation(scaleMinus, forKey: "scaleMinus")

        [self.smallButton, self.largeButton].map({$0.alpha = 1})
        for button in [self.smallButton, self.largeButton] {
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
        left.toValue = -100
        self.smallButton.layer.pop_addAnimation(left, forKey: "left")

        let right = POPSpringAnimation(propertyNamed: kPOPLayerTranslationX)
        right.springBounciness = 5
        right.fromValue = 0
        right.toValue = 100
        self.largeButton.layer.pop_addAnimation(right, forKey: "right")
    }

    func contractAddButton() {
        [self.smallButton, self.largeButton].map({$0.userInteractionEnabled = false})
        self.addButton.userInteractionEnabled = false

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
        
        self.addButton.layer.pop_addAnimation(rotate, forKey: "rotate")
        self.addButton.pop_addAnimation(scale, forKey: "scale")
        self.addButton.pop_addAnimation(color, forKey: "color")
        self.minusButton.pop_addAnimation(scaleMinus, forKey: "scaleMinus")

        for button in [self.smallButton, self.largeButton] {
            let pop = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            pop.fromValue = NSValue(CGPoint: CGPointMake(1, 1))
            pop.toValue = NSValue(CGPoint: CGPointMake(0.1, 0.1))
            pop.springBounciness = 5
            pop.removedOnCompletion = true
            button.pop_addAnimation(pop, forKey: "pop")
        }

        let left = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
        left.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        left.fromValue = -100
        left.toValue = 0
        self.smallButton.layer.pop_addAnimation(left, forKey: "left")

        let right = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
        right.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        right.fromValue = 100
        right.toValue = 0
        self.largeButton.layer.pop_addAnimation(right, forKey: "right")
    }
}
