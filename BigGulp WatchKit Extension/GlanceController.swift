import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

    @IBOutlet weak var percentageLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()

        let entry = EntryHandler().currentEntry() as Entry
        self.percentageLabel.setText("\(entry.percentage)%")
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
