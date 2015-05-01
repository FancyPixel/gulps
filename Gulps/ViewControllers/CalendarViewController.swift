import UIKit
import JTCalendar

class CalendarViewController: UIViewController, JTCalendarDataSource {

    @IBOutlet weak var calendarMenu: JTCalendarMenuView!
    @IBOutlet weak var calendarContent: JTCalendarContentView!
    @IBOutlet weak var dailyLabel: UILabel!
    var calendar: JTCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My progress"

        dailyLabel.text = ""

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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.calendar.reloadData()
        if let date = calendar.currentDateSelected {
            updateLabelWithDate(date)
        } else {
            updateLabelWithDate(NSDate())
        }
    }

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
}
