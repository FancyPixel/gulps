import UIKit
import JTCalendar
import pop
import UICountingLabel

class CalendarViewController: UIViewController, JTCalendarDataSource {

    var userDefaults = NSUserDefaults.groupUserDefaults()

    @IBOutlet weak var calendarMenu: JTCalendarMenuView!
    @IBOutlet weak var calendarContent: JTCalendarContentView!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var calendarConstraint: NSLayoutConstraint!

    @IBOutlet weak var quantityLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysCountLabel: UICountingLabel!
    @IBOutlet weak var quantityLabel: UICountingLabel!
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    var quantityLabelStartingConstant = 0.0
    var daysLabelStartingConstant = 0.0
    var shareButtonStartingConstant = 0.0
    var calendar: JTCalendar!
    var showingStats = false
    var animating = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("progress title", comment: "")

        dailyLabel.text = ""
        [daysCountLabel, quantityLabel].map { $0.format = "%d" }
        [quantityLabel, daysLabel, daysCountLabel, measureLabel].map({ $0.textColor = .mainColor() })
        shareButton.backgroundColor = .mainColor()

        self.navigationItem.rightBarButtonItem = {
            let animatedButton = AnimatedShareButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            animatedButton.addTarget(self, action: Selector("presentStats:"), forControlEvents: .TouchUpInside)
            let button = UIBarButtonItem(customView: animatedButton)
            return button
            }()

        setupCalendar()
        initAnimations()
    }

    func presentStats(sender: UIBarButtonItem) {
        animateShareView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        Globals.showPopTipOnceForKey("SHARE_HINT", userDefaults: userDefaults,
            popTipText: NSLocalizedString("share poptip", comment: ""),
            inView: view,
            fromFrame: CGRect(x: view.frame.size.width - 28, y: -10, width: 1, height: 1))

        updateStats()

        self.calendar.reloadData()
        dailyLabel.text = dateLabelString(calendar.currentDateSelected ?? NSDate())
    }

    @IBAction func shareAction(sender: AnyObject) {
        let quantitiy = EntryHandler.overallQuantity()
        let days = EntryHandler.daysTracked()
        let text = String(format: NSLocalizedString("share text", comment: ""), quantitiy, unitName(), days)
        let items = [text]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        let exclusion = [
            UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList,
            UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo
        ]
        activityController.excludedActivityTypes = exclusion
        presentViewController(activityController, animated: true, completion: nil)
    }

    // MARK: - JTCalendarDataSource

    func calendar(calendar: JTCalendar!, dataForDate date: NSDate!) -> AnyObject? {
        let entry = Entry.entryForDate(date)
        if let entry = entry {
            return 1 - (entry.percentage / 100.0)
        } else {
            return nil
        }
    }

    func calendar(calendar: JTCalendar!, didSelectDate date: NSDate!) {
        dailyLabel.text = dateLabelString(date)
    }
}

private extension CalendarViewController {
    func setupCalendar() {
        let font = UIFont(name: "KaushanScript-Regular", size: 16)

        calendar = JTCalendar()
        calendar.calendarAppearance.calendar().firstWeekday = 2
        calendar.calendarAppearance.dayDotRatio = 1.0 / 7.0
        calendar.menuMonthsView = calendarMenu
        calendar.contentView = calendarContent
        calendar.dataSource = self
        if let font = font {
            calendar.calendarAppearance.menuMonthTextFont = font
        }
        calendarMenu.reloadAppearance()
    }

    func updateStats() {
        daysCountLabel.countFromZeroTo(Float(EntryHandler.daysTracked()))
        quantityLabel.countFromZeroTo(Float(EntryHandler.overallQuantity()))
        measureLabel.text = String(format: NSLocalizedString("unit format", comment: ""), unitName())
    }

    func unitName() -> String {
        if let unit = UnitsOfMeasure(rawValue: userDefaults.integerForKey(Settings.General.UnitOfMeasure.key())) {
            return unit.nameForUnitOfMeasure()
        }
        return ""
    }

    func dateLabelString(_ date: NSDate = NSDate()) -> String {
        if let entry = Entry.entryForDate(date) {
            if (entry.percentage >= 100) {
                return NSLocalizedString("goal met", comment: "")
            } else {
                return entry.formattedPercentage()
            }
        } else {
            return ""
        }
    }
}
