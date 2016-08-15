import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

  @IBOutlet weak var percentageLabel: WKInterfaceLabel!

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
  }

  override func willActivate() {
    super.willActivate()
    if let percentage = WatchEntryHelper.sharedHelper.percentage() {
      percentageLabel.setText("\(percentage)%")
    }
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

}
