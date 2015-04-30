import UIKit
import DPMeterView

class ViewController: UIViewController {

    @IBOutlet weak var meterView: DPMeterView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DPMeterView.appearance().trackTintColor = UIColor.lightGray()
        DPMeterView.appearance().progressTintColor = UIColor.mainColor()

        meterView.setShape(MeterShape.path())
        view.backgroundColor = .clearColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let activityFlipbook = Flipbook()
        activityFlipbook.renderTargetView(meterView, duration: 1.75, imagePrefix: "activity")
        meterView.setProgress(1, duration: 1.75)
    }

}
