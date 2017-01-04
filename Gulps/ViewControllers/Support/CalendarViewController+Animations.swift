import pop

typealias CalendarAnimation = CalendarViewController
extension CalendarAnimation {

  func initAnimations() {
    quantityLabelStartingConstant = Double(quantityLabelConstraint.constant)
    quantityLabelConstraint.constant = view.frame.size.height

    daysLabelStartingConstant = Double(daysLabelConstraint.constant)
    daysLabelConstraint.constant = view.frame.size.height

    shareButtonStartingConstant = Double(shareButtonConstraint.constant)
    shareButtonConstraint.constant = view.frame.size.height
  }

  func animateShareView() {
    if animating == true {
      return
    }

    animating = true
    if let button = self.navigationItem.rightBarButtonItem?.customView as? AnimatedShareButton {
      button.showsMenu = !button.showsMenu
    }
    if (showingStats) {
      let slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideIn?.springBounciness = 5
      slideIn?.springSpeed = 8
      slideIn?.fromValue = calendarConstraint.constant
      slideIn?.toValue = 0
      slideIn?.removedOnCompletion = true
      slideIn?.beginTime = CACurrentMediaTime() + 0.35
      calendarConstraint.pop_add(slideIn, forKey: "slideAway")

      var slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideAway?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      slideAway?.fromValue = shareButtonConstraint.constant
      slideAway?.toValue = view.frame.size.height
      slideAway?.removedOnCompletion = true
      shareButtonConstraint.pop_add(slideAway, forKey: "slideInButton")

      slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideAway?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      slideAway?.fromValue = quantityLabelConstraint.constant
      slideAway?.toValue = view.frame.size.height
      slideAway?.removedOnCompletion = true
      slideAway?.beginTime = CACurrentMediaTime() + 0.20
      quantityLabelConstraint.pop_add(slideAway, forKey: "slideInQuantity")

      slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideAway?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      slideAway?.fromValue = daysLabelConstraint.constant
      slideAway?.toValue = view.frame.size.height
      slideAway?.removedOnCompletion = true
      slideAway?.beginTime = CACurrentMediaTime() + 0.10
      daysLabelConstraint.pop_add(slideAway, forKey: "slideInDays")

      slideAway?.completionBlock = { (_, _) in
        self.showingStats = false
        self.animating = false
      }
    } else {
      let slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideAway?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      slideAway?.fromValue = calendarConstraint.constant
      slideAway?.toValue = -view.frame.size.height
      slideAway?.removedOnCompletion = true
      slideAway?.duration = 0.6
      calendarConstraint.pop_add(slideAway, forKey: "slideAway")

      var slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideIn?.springBounciness = 5
      slideIn?.springSpeed = 8
      slideIn?.fromValue = quantityLabelConstraint.constant
      slideIn?.toValue = quantityLabelStartingConstant
      slideIn?.removedOnCompletion = true
      slideIn?.beginTime = CACurrentMediaTime() + 0.35
      quantityLabelConstraint.pop_add(slideIn, forKey: "slideInQuantity")

      slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideIn?.springBounciness = 5
      slideIn?.springSpeed = 8
      slideIn?.fromValue = daysLabelConstraint.constant
      slideIn?.toValue = daysLabelStartingConstant
      slideIn?.removedOnCompletion = true
      slideIn?.beginTime = CACurrentMediaTime() + 0.50
      daysLabelConstraint.pop_add(slideIn, forKey: "slideInDays")

      slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
      slideIn?.springBounciness = 5
      slideIn?.springSpeed = 8
      slideIn?.fromValue = shareButtonConstraint.constant
      slideIn?.toValue = shareButtonStartingConstant
      slideIn?.removedOnCompletion = true
      slideIn?.beginTime = CACurrentMediaTime() + 0.65
      shareButtonConstraint.pop_add(slideIn, forKey: "slideInButton")

      slideIn?.completionBlock = { (_, _) in
        self.showingStats = true
        self.animating = false
      }
    }

  }

}
