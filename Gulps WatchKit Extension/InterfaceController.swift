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

    @IBOutlet weak var interfaceGroup: WKInterfaceGroup!
    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    let entryHandler = EntryHandler()
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.wormhole.listenForMessageWithIdentifier("mainUpdate", listener: { (_) -> Void in
            self.reloadAndUpdateUI()
        })
        self.wormhole.listenForMessageWithIdentifier("todayUpdate", listener: { (_) -> Void in
            self.reloadAndUpdateUI()
        })
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {

    }

    func reloadAndUpdateUI() {
        let entry = EntryHandler().currentEntry() as Entry
        let percentage = Int(ceil(entry.percentage / 10.0))
        let image = "progress-\(percentage)-watch"
        self.interfaceGroup.setBackgroundImageNamed(image)
        self.goalLabel.setText("DAILY GOAL: \(entry.formattedPercentage())")
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
