import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

    @IBOutlet weak var percentageLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()

        self.percentageLabel.setText("\(EntryHelper.sharedHelper.percentage())%")
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
