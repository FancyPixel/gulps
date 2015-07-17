//
//  FeedbackViewController.swift
//  Gulps
//
//  Created by Andrea Mazzini on 17/07/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var negativeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        negativeButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func reviewAction() {
        self.dismissViewControllerAnimated(true) {
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id979057304")!)
        }
    }
    
    @IBAction func negativeAction() {
        self.dismissViewControllerAnimated(true) {}
    }

    @IBAction func contactAction() {
        self.dismissViewControllerAnimated(true) {
            UIApplication.sharedApplication().openURL(NSURL(string: "mailto:gulps@fancypixel.it")!)
        }
    }
}
