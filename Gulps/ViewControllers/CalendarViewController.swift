import UIKit
import JTCalendar
import pop
import UICountingLabel

class CalendarViewController: UIViewController, JTCalendarDataSource {

  let userDefaults = UserDefaults.groupUserDefaults()

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
  let calendar = JTCalendar()
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
    [daysCountLabel, quantityLabel].forEach { $0.format = "%d" }
    [quantityLabel, daysLabel, daysCountLabel, measureLabel].forEach { $0.textColor = .palette_main }
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

  func presentStats(_ sender: UIBarButtonItem) {
    animateShareView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    Globals.showPopTipOnceForKey("SHARE_HINT", userDefaults: userDefaults,
                                 popTipText: NSLocalizedString("share poptip", comment: ""),
                                 inView: view,
                                 fromFrame: CGRect(x: view.frame.size.width - 28, y: -10, width: 1, height: 1))

    updateStats()

    calendar.reloadData()
    dailyLabel.text = dateLabelString(calendar.currentDateSelected ?? Date())
  }

  @IBAction func shareAction(_ sender: AnyObject) {
    let quantity = Int(EntryHandler.sharedHandler.overallQuantity())
    let days = EntryHandler.sharedHandler.daysTracked()
    let text = String(format: NSLocalizedString("share text", comment: ""), quantity, unitName(), days)
    let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    activityController.excludedActivityTypes = shareExclusions
    present(activityController, animated: true, completion: nil)
  }

  // MARK: - JTCalendarDataSource
  func calendar(_ calendar: JTCalendar!, dataFor date: Date!) -> Any! {
    if let entry = EntryHandler.sharedHandler.entryForDate(date) {
      return 1 - Double(entry.percentage / 100.0)
    } else {
      return nil
    }
  }

  func calendar(_ calendar: JTCalendar!, didSelect date: Date!) {
    dailyLabel.text = dateLabelString(date)
  }
}

private extension CalendarViewController {
  func setupCalendar() {
    let font = UIFont(name: "KaushanScript-Regular", size: 16)

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
