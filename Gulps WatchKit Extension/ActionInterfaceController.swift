//
//  ActionInterfaceController.swift
//  BigGulp
//
//  Created by Andrea Mazzini on 08/03/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import WatchKit
import Foundation
import MMWormhole

class ActionInterfaceController: WKInterfaceController {

    @IBOutlet weak var smallButton: WKInterfaceButton!
    @IBOutlet weak var bigButton: WKInterfaceButton!
    let entryHandler = EntryHandler()
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    @IBAction func smallButtonAction() {
        updateWithGulp(Settings.Gulp.Small.key())
    }

    @IBAction func bigButtonAction() {
        updateWithGulp(Settings.Gulp.Big.key())
    }

    func updateWithGulp(gulp: String) {
        self.entryHandler.addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(gulp))
        self.wormhole.passMessageObject("update", identifier: "watchUpdate")
        self.dismissController()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
}