//
//  TodayViewController.swift
//  BigGulpToday
//
//  Created by Andrea Mazzini on 20/02/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var bigGulpButton: UIButton!
    @IBOutlet weak var smallGulpButton: UIButton!
    @IBOutlet weak var smallConfirmButton: UIButton!
    @IBOutlet weak var bigConfirmButton: UIButton!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet var entryHandler: EntryHandler!
    
    var gulpSize = Settings.Gulp.Small
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.it.fancypixel.BigGulp", optionalDirectory: "biggulp")

    override func viewDidLoad() {
        super.viewDidLoad()

        [bigConfirmButton, smallConfirmButton].map({$0.transform = CGAffineTransformMakeScale(0.001, 0.001)})
        self.title = "Gulps"
        self.preferredContentSize = CGSizeMake(0, 108)
        updateUI()
        updateLabels()
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        updateUI()
        updateLabels()
        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func updateUI() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        UIView.transitionWithView(self.summaryLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
            let quantity = numberFormatter.stringFromNumber(self.entryHandler.currentEntry().quantity)!
            let percentage = numberFormatter.stringFromNumber(ceil(self.entryHandler.currentEntry().percentage))!
            self.summaryLabel.text = "\(quantity) liters drank today (\(percentage)% of your goal)"
            }, completion: nil)
    }
    
    func updateLabels() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        let userDefaults = NSUserDefaults.groupUserDefaults()
        
        var suffix = ""
        if let unit = UnitsOfMeasure(rawValue: userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
            suffix = unit.suffixForUnitOfMeasure()
        }
        
        self.smallLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Small.key()))!)\(suffix)"
        self.bigLabel.text = "\(numberFormatter.stringFromNumber(userDefaults.doubleForKey(Settings.Gulp.Big.key()))!)\(suffix)"
    }

    func confirmAction() {
        self.smallConfirmButton.backgroundColor = (self.gulpSize == Settings.Gulp.Small) ? UIColor.confirmColor() : UIColor.destructiveColor()
        self.bigConfirmButton.backgroundColor = (self.gulpSize == Settings.Gulp.Big) ? UIColor.confirmColor() : UIColor.destructiveColor()
        self.smallConfirmButton.setImage(UIImage(named: (self.gulpSize == Settings.Gulp.Small) ? "tiny-check" : "tiny-x"), forState: .Normal)
        self.bigConfirmButton.setImage(UIImage(named: (self.gulpSize == Settings.Gulp.Big) ? "tiny-check" : "tiny-x"), forState: .Normal)
        self.smallLabel.text = (self.gulpSize == Settings.Gulp.Small) ? "Confirm" : "Never mind"
        self.bigLabel.text = (self.gulpSize == Settings.Gulp.Small) ? "Never mind" : "Confirm"
        self.showConfirmButtons()
    }

    @IBAction func smallGulp(sender: UIButton) {
        self.gulpSize = Settings.Gulp.Small
        confirmAction()
    }

    @IBAction func bigGulp(sender: UIButton) {
        self.gulpSize = Settings.Gulp.Big
        confirmAction()
    }

    @IBAction func smallConfirmAction() {
        if (self.gulpSize == .Small) {
            addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Small.key()))
        }
        hideConfirmButtons()
        updateLabels()
    }
    
    @IBAction func bigConfirmAction() {
        if (self.gulpSize == .Big) {
            addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(Settings.Gulp.Big.key()))
        }
        updateLabels()
        hideConfirmButtons()
    }
    
    func addGulp(quantity: Double) {
        self.entryHandler.addGulp(quantity)
        self.summaryLabel.text = "Way to go!"
        self.wormhole.passMessageObject("update", identifier: "todayUpdate")
        updateLabels()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.updateUI()
        }
    }
}
