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

        self.dailyLabel.text = ""

        let font = UIFont(name: "KaushanScript-Regular", size: 16)

        self.calendar = JTCalendar()
        self.calendar.calendarAppearance.calendar().firstWeekday = 2
        self.calendar.calendarAppearance.dayDotRatio = 1.0 / 7.0
        self.calendar.menuMonthsView = self.calendarMenu
        self.calendar.contentView = self.calendarContent
        self.calendar.dataSource = self
        if let font = font {
            self.calendar.calendarAppearance.menuMonthTextFont = font
        }
        self.calendarMenu.reloadAppearance()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.calendar.reloadData()
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
        if let entry = Entry.entryForDate(date) {
            if (entry.percentage >= 100) {
                self.dailyLabel.text = "Goal Met!"
            } else {
                self.dailyLabel.text = entry.formattedPercentage()
            }
        } else {
            self.dailyLabel.text = ""
        }
    }
}
