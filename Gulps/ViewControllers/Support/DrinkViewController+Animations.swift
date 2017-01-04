import pop

extension DrinkViewController {

  func initAnimation() {
    smallButton.alpha = 0
    largeButton.alpha = 0
    starButton.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
  }

  func animateStarButton() {
    let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
    rotate?.toValue = 2 * M_PI - M_PI_4 / 2
    rotate?.springBounciness = 5
    rotate?.removedOnCompletion = true

    let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    scale?.toValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
    scale?.removedOnCompletion = true
    scale?.completionBlock = {(_,_) in
      let sway = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
      sway?.fromValue = -M_PI_4 / 2
      sway?.toValue = M_PI_4 / 2
      sway?.duration = 0.75
      sway?.repeatForever = true
      sway?.autoreverses = true
      self.starButton.layer.pop_add(sway, forKey: "sway")
    }

    starButton.pop_add(scale, forKey: "scale")
    starButton.layer.pop_add(rotate, forKey: "rotate")
  }

  func expandAddButton() {
    addButton.isUserInteractionEnabled = false

    let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
    rotate?.fromValue = 0
    rotate?.toValue = -M_PI + M_PI_4
    rotate?.springBounciness = 5
    rotate?.removedOnCompletion = true
    rotate?.completionBlock = {(_, _) in
      self.addButton.isUserInteractionEnabled = true
      _ = [self.smallButton, self.largeButton].map({$0.isUserInteractionEnabled = true})
      self.expanded = true
    }

    let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    scale?.fromValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scale?.toValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
    scale?.springBounciness = 5
    scale?.removedOnCompletion = true

    let scaleMinus = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
    scaleMinus?.fromValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scaleMinus?.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
    scaleMinus?.removedOnCompletion = true

    let color = POPSpringAnimation(propertyNamed: kPOPViewBackgroundColor)
    color?.fromValue = UIColor.palette_main
    color?.toValue = UIColor.palette_destructive
    color?.springBounciness = 5
    color?.removedOnCompletion = true

    addButton.layer.pop_add(rotate, forKey: "rotate")
    addButton.pop_add(scale, forKey: "scale")
    addButton.pop_add(color, forKey: "color")
    minusButton.pop_add(scaleMinus, forKey: "scaleMinus")

    [smallButton, largeButton].forEach {$0.alpha = 1}
    for button in [smallButton, largeButton] {
      let pop = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
      pop?.fromValue = NSValue(cgPoint: CGPoint(x: 0.1, y: 0.1))
      pop?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
      pop?.springBounciness = 5
      pop?.removedOnCompletion = true
      button?.pop_add(pop, forKey: "pop")
    }

    let left = POPSpringAnimation(propertyNamed: kPOPLayerTranslationX)
    left?.springBounciness = 5
    left?.fromValue = 0
    left?.toValue = -100
    smallButton.layer.pop_add(left, forKey: "left")

    let right = POPSpringAnimation(propertyNamed: kPOPLayerTranslationX)
    right?.springBounciness = 5
    right?.fromValue = 0
    right?.toValue = 100
    largeButton.layer.pop_add(right, forKey: "right")
  }

  func contractAddButton() {
    [smallButton, largeButton].forEach {$0.isUserInteractionEnabled = false}
    addButton.isUserInteractionEnabled = false

    let rotate = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
    rotate?.fromValue = -M_PI + M_PI_4
    rotate?.toValue = 0
    rotate?.springBounciness = 5

    rotate?.completionBlock = {(_, _) in
      self.addButton.isUserInteractionEnabled = true
      self.expanded = false
    }

    let scale = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    scale?.fromValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
    scale?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scale?.springBounciness = 5

    let color = POPSpringAnimation(propertyNamed: kPOPViewBackgroundColor)
    color?.fromValue = UIColor.palette_destructive
    color?.toValue = UIColor.palette_main
    color?.springBounciness = 5

    let scaleMinus = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
    scaleMinus?.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
    scaleMinus?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
    scaleMinus?.removedOnCompletion = true

    addButton.layer.pop_add(rotate, forKey: "rotate")
    addButton.pop_add(scale, forKey: "scale")
    addButton.pop_add(color, forKey: "color")
    minusButton.pop_add(scaleMinus, forKey: "scaleMinus")

    for button in [smallButton, largeButton] {
      let pop = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
      pop?.fromValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
      pop?.toValue = NSValue(cgPoint: CGPoint(x: 0.1, y: 0.1))
      pop?.springBounciness = 5
      pop?.removedOnCompletion = true
      button?.pop_add(pop, forKey: "pop")
    }

    let left = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
    left?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    left?.fromValue = -100
    left?.toValue = 0
    smallButton.layer.pop_add(left, forKey: "left")

    let right = POPBasicAnimation(propertyNamed: kPOPLayerTranslationX)
    right?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    right?.fromValue = 100
    right?.toValue = 0
    largeButton.layer.pop_add(right, forKey: "right")
  }
}
