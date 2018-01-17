import UIKit
import CVCalendar
import pop
import UICountingLabel

class CalendarViewController: UIViewController {

    let userDefaults = UserDefaults.groupUserDefaults()

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarMenu: CVCalendarMenuView!
    @IBOutlet weak var calendarContent: CVCalendarView!
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
    var showingStats = false
    var animating = false

    let shareExclusions = [
        UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.addToReadingList,
        UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("progress title", comment: "")

        dailyLabel.text = ""
        [daysCountLabel, quantityLabel].forEach {
            $0.format = "%d"
        }
        [quantityLabel, daysLabel, daysCountLabel, measureLabel].forEach {
            $0.textColor = .palette_main
        }
        shareButton.backgroundColor = .palette_main

        self.navigationItem.rightBarButtonItem = {
            let animatedButton = AnimatedShareButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            animatedButton.addTarget(self, action: #selector(CalendarViewController.presentStats(_:)), for: .touchUpInside)
            let button = UIBarButtonItem(customView: animatedButton)
            return button
        }()

        setupCalendar()
        initAnimations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCalendarView()
    }

    @objc func presentStats(_ sender: UIBarButtonItem) {
        animateShareView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Globals.showPopTipOnceForKey("SHARE_HINT", userDefaults: userDefaults,
                popTipText: NSLocalizedString("share poptip", comment: ""),
                inView: view,
                fromFrame: CGRect(x: view.frame.size.width - 28, y: -10, width: 1, height: 1))

        updateStats()
        dailyLabel.text = dateLabelString(Date())
        updateCalendarView()
    }

    private func updateCalendarView() {
        calendarMenu.commitMenuViewUpdate()
        calendarContent.commitCalendarViewUpdate()
    }

    @IBAction func shareAction(_ sender: AnyObject) {
        let quantity = Int(EntryHandler.sharedHandler.overallQuantity())
        let days = EntryHandler.sharedHandler.daysTracked()
        let text = String(format: NSLocalizedString("share text", comment: ""), quantity, unitName(), days)
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityController.excludedActivityTypes = shareExclusions
        present(activityController, animated: true, completion: nil)
    }
}

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    func presentationMode() -> CalendarMode {
        return .monthView
    }

    func firstWeekday() -> Weekday {
        return .monday
    }

    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        guard let date = dayView.date.convertedDate() else {
            return
        }
        dailyLabel.text = dateLabelString(date)
    }

    func latestSelectableDate() -> Date {
        return Date()
    }

    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        guard let percentage = percentage(for: dayView.date.convertedDate()) else {
            return false
        }
        return percentage > 0.0
    }

    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        guard let percentage = percentage(for: dayView.date.convertedDate()) else {
            return []
        }
        return percentage >= 1.0 ? [.palette_main] : [.palette_destructive]
    }

    private func percentage(for date: Date?) -> Double? {
        guard let date = date,
              let entry = EntryHandler.sharedHandler.entryForDate(date) else {
            return nil
        }
        return Double(entry.percentage / 100.0)
    }

    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return .palette_main
    }

    func presentedDateUpdated(_ date: CVDate) {
        monthLabel.text = date.globalDescription
    }
}

extension CalendarViewController {
    func setupCalendar() {
        calendarContent.calendarAppearanceDelegate = self
        calendarMenu.menuViewDelegate = self
        calendarContent.calendarDelegate = self
        monthLabel.text = CVDate(date: Date()).globalDescription
        if let font = UIFont(name: "KaushanScript-Regular", size: 16) {
            monthLabel.font = font
            monthLabel.textAlignment = .center
            monthLabel.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00)
        }
    }

    func updateStats() {
        daysCountLabel.countFromZero(to: CGFloat(EntryHandler.sharedHandler.daysTracked()))
        quantityLabel.countFromZero(to: CGFloat(EntryHandler.sharedHandler.overallQuantity()))
        measureLabel.text = String(format: NSLocalizedString("unit format", comment: ""), unitName())
    }

    func unitName() -> String {
        if let unit = Constants.UnitsOfMeasure(rawValue: userDefaults.integer(forKey: Constants.General.unitOfMeasure.key())) {
            return unit.nameForUnitOfMeasure()
        }
        return ""
    }

    func dateLabelString(_ date: Date = Date()) -> String {
        if let entry = EntryHandler.sharedHandler.entryForDate(date) {
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
