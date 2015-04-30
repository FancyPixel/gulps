//
//  NotificationController.swift
//  BigGulp WatchKit Extension
//
//  Created by Andrea Mazzini on 08/03/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import WatchKit
import Foundation

class NotificationController: WKUserNotificationInterfaceController {

    override init() {
        super.init()
        self.setTitle("Gulps")
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
}
