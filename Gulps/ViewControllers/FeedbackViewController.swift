//
//  FeedbackViewController.swift
//  Gulps
//
//  Created by Andrea Mazzini on 17/07/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

  @IBOutlet weak var negativeButton: UIButton?
  override func viewDidLoad() {
    super.viewDidLoad()

    negativeButton?.layer.borderColor = UIColor.white.cgColor
  }

  override var prefersStatusBarHidden : Bool {
    return true
  }

  @IBAction func reviewAction() {
    self.dismiss(animated: true) {
      UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id979057304")!)
    }
  }

  @IBAction func negativeAction() {
    self.dismiss(animated: true) {}
  }

  @IBAction func contactAction() {
    self.dismiss(animated: true) {
      UIApplication.shared.openURL(URL(string: "mailto:gulps@fancypixel.it")!)
    }
  }
}
