//
//  AnimatedShareView.swift
//  Gulps
//
//  Created by Andrea Mazzini on 20/05/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import CoreGraphics
import QuartzCore
import UIKit

class AnimatedShareButton: UIButton {

  var box: CAShapeLayer! = CAShapeLayer()
  var leftShoulder: CAShapeLayer! = CAShapeLayer()
  var rightShoulder: CAShapeLayer! = CAShapeLayer()
  var arrowBody: CAShapeLayer! = CAShapeLayer()

  let boxStrokeStart: CGFloat = 0.18
  let boxStrokeEnd: CGFloat = 0.82

  let arrowStrokeStart: CGFloat = 0.028
  let arrowStrokeEnd: CGFloat = 0.111

  let shoulderStrokeStart: CGFloat = 0.53
  let shoulderStrokeEnd: CGFloat = 1

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let strokeWidth = CGFloat(1.5)

    box.path = {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: frame.size.width - strokeWidth / 2, y: frame.size.height * 0.2))
      path.addLine(to: CGPoint(x: strokeWidth / 2, y: frame.size.height * 0.2))
      path.addLine(to: CGPoint(x: strokeWidth / 2, y: frame.size.height - strokeWidth / 2))
      path.addLine(to: CGPoint(x: frame.size.width - strokeWidth / 2, y: frame.size.height - strokeWidth / 2))
      path.addLine(to: CGPoint(x: frame.size.width - strokeWidth / 2, y: frame.size.height * 0.2))
      path.addLine(to: CGPoint(x: strokeWidth / 2, y: frame.size.height * 0.2))
      return path
    }()

    arrowBody.path = {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: frame.size.width * 0.5 - strokeWidth / 2, y: 0))
      path.addLine(to: CGPoint(x: frame.size.width * 0.5 - strokeWidth / 2, y: frame.size.width * 0.7 - strokeWidth / 2))
      return path
    }()

    leftShoulder.path = {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: frame.size.width * 0.15, y: -frame.size.height * 0.15))
      path.addLine(to: CGPoint(x: 0, y: 0))
      path.addLine(to: CGPoint(x: 0, y: frame.size.width * 0.2 - strokeWidth / 2))
      return path
    }()

    rightShoulder.path = {
      let path = CGMutablePath()
      path.move(to: CGPoint(x: -frame.size.width * 0.15, y: -frame.size.height * 0.15))
      path.addLine(to: CGPoint(x: 0, y: 0))
      path.addLine(to: CGPoint(x: 0, y: frame.size.width * 0.2 - strokeWidth / 2))
      return path
    }()


    for layer in [box, arrowBody, leftShoulder, rightShoulder] {
      layer?.fillColor = nil
      layer?.strokeColor = UIColor.white.cgColor
      layer?.lineWidth = strokeWidth
      layer?.miterLimit = strokeWidth
      layer?.lineCap = kCALineCapRound
      layer?.masksToBounds = true

      let strokingPath = CGPath(__byStroking: (layer?.path!)!, transform: nil, lineWidth: strokeWidth, lineCap: CGLineCap.round, lineJoin: CGLineJoin.miter, miterLimit: strokeWidth)

      layer?.bounds = (strokingPath?.boundingBoxOfPath)!

      layer?.actions = [
        "strokeStart": NSNull(),
        "strokeEnd": NSNull(),
        "transform": NSNull()
      ]

      self.layer.addSublayer(layer!)
    }

    self.box.strokeStart = boxStrokeStart
    self.box.strokeEnd = boxStrokeEnd

    self.leftShoulder.strokeEnd = shoulderStrokeStart
    self.rightShoulder.strokeEnd = shoulderStrokeStart

    self.box.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    self.arrowBody.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.2)
    self.leftShoulder.position = CGPoint(x: frame.size.width * 0.425, y: frame.size.height * 0.025)
    self.rightShoulder.position = CGPoint(x: frame.size.width * 0.575, y: frame.size.height * 0.025)
  }

  var showsMenu: Bool = true {
    didSet {
      var strokeStart = CABasicAnimation(keyPath: "strokeStart")
      let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")

      // Box
      if self.showsMenu {
        strokeStart.toValue = boxStrokeStart
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)

        strokeEnd.toValue = boxStrokeEnd
        strokeEnd.duration = 0.5
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
      } else {
        strokeStart.toValue = 0
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)

        strokeEnd.toValue = 1
        strokeEnd.duration = 0.5
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)
      }

      self.box.ocb_applyAnimation(strokeStart)
      self.box.ocb_applyAnimation(strokeEnd)


      // Arrow body
      strokeStart = CABasicAnimation(keyPath: "strokeStart")

      if self.showsMenu {
        strokeStart.toValue = 0
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
      } else {
        strokeStart.toValue = 1
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)
      }

      self.arrowBody.ocb_applyAnimation(strokeStart)


      // Left shoulder
      strokeStart = CABasicAnimation(keyPath: "strokeStart")

      if self.showsMenu {
        strokeStart.toValue = 0
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)

        strokeEnd.toValue = shoulderStrokeStart
        strokeEnd.duration = 0.5
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
      } else {
        strokeStart.toValue = shoulderStrokeStart
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)

        strokeEnd.toValue = 1
        strokeEnd.duration = 0.5
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
      }

      self.leftShoulder.ocb_applyAnimation(strokeStart)
      self.leftShoulder.ocb_applyAnimation(strokeEnd)
      self.rightShoulder.ocb_applyAnimation(strokeStart)
      self.rightShoulder.ocb_applyAnimation(strokeEnd)
    }
  }
}

extension CALayer {
  // Thanks to https://github.com/robb/hamburger-button
  func ocb_applyAnimation(_ animation: CABasicAnimation) {
    if let copy = animation.copy() as? CABasicAnimation, let keyPath = copy.keyPath {

      if copy.fromValue == nil {
        copy.fromValue = self.presentation()?.value(forKeyPath: keyPath)
      }

      self.add(copy, forKey: copy.keyPath)
      self.setValue(copy.toValue, forKeyPath:keyPath)
    }
  }
}
