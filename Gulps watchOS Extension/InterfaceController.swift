//
//  InterfaceController.swift
//  Gulps watchOS Extension
//
//  Created by Andrea Mazzini on 18/09/15.
//  Copyright © 2015 Fancy Pixel. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    @IBOutlet weak var progressImage: WKInterfaceImage!
    var previousPercentage = 0.0

    let session = WCSession.defaultSession()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        previousPercentage = 0
        progressImage.setImageNamed("activity-")
        reloadAndUpdateUI(0)
    }

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let percentage = applicationContext["percentage"] as? Double {
            reloadAndUpdateUI(percentage)
        }
    }

    @IBAction func addSmallGulpAction() {
        updateWithGulp(Constants.Gulp.Small.key())
    }

    @IBAction func addBigGulpAction() {
        updateWithGulp(Constants.Gulp.Big.key())
    }

    func updateWithGulp(size: String) {
        let applicationData = ["value": String(Constants.Gulp.Small.key())]

        // Optimistically update before sending the data
        // TODO: implement

        // Send the update to the main app
        session.sendMessage(applicationData, replyHandler: {
            (data: [String : AnyObject]) in
            // Get the updated value
            if let percentage = data["percentage"] as? Double {
                self.reloadAndUpdateUI(percentage)
            }
            }) { (error) in
        }
    }

    func reloadAndUpdateUI(percentage: Double) {
        var delta = Int(percentage - previousPercentage)
        if (delta < 0) {
            // animate in reverse using negative duration
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(percentage), -delta), duration: -1.0, repeatCount: 1)
        } else {
            if (delta == 0) {
                // if the range's length is 0, no image is loaded
                delta = 1
            }
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
        }
        goalLabel.setText(NSLocalizedString("daily goal:", comment: "") + percentage.formattedPercentage())
        previousPercentage = percentage
    }

    override func willActivate() {
        super.willActivate()

        if (WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
