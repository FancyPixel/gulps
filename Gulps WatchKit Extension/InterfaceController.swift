//
//  InterfaceController.swift
//  BigGulp WatchKit Extension
//
//  Created by Andrea Mazzini on 08/03/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import WatchKit
import Foundation
import MMWormhole

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    @IBOutlet weak var progressImage: WKInterfaceImage!

    let entryHandler = EntryHandler()
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")
    var previousPercentage = 0.0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        wormhole.listenForMessageWithIdentifier("mainUpdate") { (_) -> Void in
            self.reloadAndUpdateUI()
        }
        wormhole.listenForMessageWithIdentifier("todayUpdate") { (_) -> Void in
            self.reloadAndUpdateUI()
        }

        let entry = EntryHandler().currentEntry() as Entry
        previousPercentage = entry.percentage
        progressImage.setImageNamed("activity-")
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {

    }

    func reloadAndUpdateUI() {
        let entry = EntryHandler().currentEntry() as Entry
        var delta = Int(entry.percentage - previousPercentage)
        if (delta < 0) {
            // can't animate backwards
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(0, Int(entry.percentage)), duration: 1.0, repeatCount: 1)
        } else {
            if (delta == 0) {
                // if the range's length is 0, no image is loaded
                delta = 1
            }
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
        }
        goalLabel.setText("DAILY GOAL: \(entry.formattedPercentage())")
        previousPercentage = entry.percentage
    }

    @IBAction func addMenuAction() {
        self.presentControllerWithName("ActionInterfaceController", context:nil)
    }

    override func willActivate() {
        super.willActivate()
        reloadAndUpdateUI()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
