import UIKit
import JTCalendar
import pop
import UICountingLabel

class CalendarViewController: UIViewController, JTCalendarDataSource {

    @IBOutlet weak var calendarMenu: JTCalendarMenuView!
    @IBOutlet weak var calendarContent: JTCalendarContentView!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var calendarConstraint: NSLayoutConstraint!
    @IBOutlet weak var quantityLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysLabel: UICountingLabel!
    @IBOutlet weak var quantityLabel: UICountingLabel!
    @IBOutlet weak var measureLabel: UILabel!
    var quantityLabelStartingConstant = 0.0
    var daysLabelStartingConstant = 0.0
    var calendar: JTCalendar!
    var showingStats = false
    var animating = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My progress"

        dailyLabel.text = ""

        let animatedButton = AnimatedShareButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        animatedButton.addTarget(self, action: Selector("presentStats:"), forControlEvents: .TouchUpInside)
        let button = UIBarButtonItem(customView: animatedButton)
        self.navigationItem.rightBarButtonItem = button // UIBarButtonItem(image: UIImage(named: "stats-icon"), style: .Plain, target: self, action: Selector("presentStats:"))
        
        setupCalendar()

        quantityLabelStartingConstant = Double(quantityLabelConstraint.constant)
        quantityLabelConstraint.constant = view.frame.size.height

        daysLabelStartingConstant = Double(daysLabelConstraint.constant)
        daysLabelConstraint.constant = view.frame.size.height
    }

    func presentStats(sender: UIBarButtonItem) {
        if animating == true {
            return
        }

        animating = true
        if let button = self.navigationItem.rightBarButtonItem {
            let animatedButton: AnimatedShareButton = button.customView as! AnimatedShareButton
            animatedButton.showsMenu = !animatedButton.showsMenu
        }
        if (showingStats) {
            let slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideIn.springBounciness = 5
            slideIn.springSpeed = 8
            slideIn.fromValue = calendarConstraint.constant
            slideIn.toValue = 0
            slideIn.removedOnCompletion = true
            slideIn.beginTime = CACurrentMediaTime() + 0.35
            calendarConstraint.pop_addAnimation(slideIn, forKey: "slideAway")

            var slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideAway.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            slideAway.fromValue = quantityLabelConstraint.constant
            slideAway.toValue = view.frame.size.height
            slideAway.removedOnCompletion = true
            slideAway.beginTime = CACurrentMediaTime() + 0.10
            quantityLabelConstraint.pop_addAnimation(slideAway, forKey: "slideInQuantity")

            slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideAway.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            slideAway.fromValue = daysLabelConstraint.constant
            slideAway.toValue = view.frame.size.height
            slideAway.removedOnCompletion = true
            daysLabelConstraint.pop_addAnimation(slideAway, forKey: "slideInDays")
            slideAway.completionBlock = { (_, _) in
                self.showingStats = false
                self.animating = false
            }
        } else {
            let slideAway = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideAway.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            slideAway.fromValue = calendarConstraint.constant
            slideAway.toValue = -view.frame.size.height
            slideAway.removedOnCompletion = true
            slideAway.duration = 0.6
            calendarConstraint.pop_addAnimation(slideAway, forKey: "slideAway")

            var slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideIn.springBounciness = 5
            slideIn.springSpeed = 8
            slideIn.fromValue = quantityLabelConstraint.constant
            slideIn.toValue = quantityLabelStartingConstant
            slideIn.removedOnCompletion = true
            slideIn.beginTime = CACurrentMediaTime() + 0.35
            quantityLabelConstraint.pop_addAnimation(slideIn, forKey: "slideInQuantity")

            slideIn = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            slideIn.springBounciness = 5
            slideIn.springSpeed = 8
            slideIn.fromValue = daysLabelConstraint.constant
            slideIn.toValue = daysLabelStartingConstant
            slideIn.removedOnCompletion = true
            slideIn.beginTime = CACurrentMediaTime() + 0.50
            daysLabelConstraint.pop_addAnimation(slideIn, forKey: "slideInDays")
            slideIn.completionBlock = { (_, _) in
                self.showingStats = true
                self.animating = false
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        updateStats()

        self.calendar.reloadData()
        if let date = calendar.currentDateSelected {
            updateLabelWithDate(date)
        } else {
            updateLabelWithDate(NSDate())
        }
    }

    func updateStats() {
        [daysLabel, quantityLabel].map { $0.format = "%d" }
        daysLabel.countFromZeroTo(Float(EntryHandler.overallQuantity()))
        quantityLabel.countFromZeroTo(Float(EntryHandler.daysTracked()))
        if let unit = UnitsOfMeasure(rawValue: NSUserDefaults.groupUserDefaults().integerForKey(Settings.General.UnitOfMeasure.key())) {
            let unitName = unit.nameForUnitOfMeasure()
            measureLabel.text = "\(unitName) drank in the last"
        }
    }

    func updateLabelWithDate(date: NSDate!) {
        if let entry = Entry.entryForDate(date) {
            if (entry.percentage >= 100) {
                dailyLabel.text = "Goal Met!"
            } else {
                dailyLabel.text = entry.formattedPercentage()
            }
        } else {
            dailyLabel.text = ""
        }
    }

    @IBAction func shareAction(sender: AnyObject) {
        let quantitiy = EntryHandler.overallQuantity()
        let days = EntryHandler.daysTracked()
        let text = "Keeping healthy! I drank \(quantitiy) liters of water in the last \(days) days"
        let items = [text]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo]
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
        updateLabelWithDate(date)
    }
}

private extension CalendarViewController {
    private func setupCalendar() {
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
}
