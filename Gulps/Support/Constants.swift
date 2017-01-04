import Foundation

public enum Constants {
  public static func bundle() -> String {
    return "it.fancypixel.BigGulp"
  }

  public enum WatchContext: Int {
    case current, date
    public func key() -> String {
      switch self {
      case .current:
        return "WATCH_CURRENT"
      case .date:
        return "WATCH_DATE"
      }
    }
  }

  public enum UnitsOfMeasure: Int {
    case liters, ounces

    func nameForUnitOfMeasure() -> String {
      switch self {
      case .liters:
        return NSLocalizedString("Liters", comment: "")
      case .ounces:
        return NSLocalizedString("Ounces", comment: "")
      }
    }

    func suffixForUnitOfMeasure() -> String {
      switch self {
      case .liters:
        return "L"
      case .ounces:
        return "Oz"
      }
    }
  }

  public enum General: Int {
    case unitOfMeasure, onboardingShown

    public func key() -> String {
      switch self {
      case .unitOfMeasure:
        return "UNIT_OF_MEASURE"
      case .onboardingShown:
        return "ONBOARDING_SHOWN"
      }
    }
  }

  public enum Gulp: Int {
    case big, small, goal
    public func key() -> String {
      switch self {
      case .big:
        return "GULP_BIG"
      case .small:
        return "GULP_SMALL"
      case .goal:
        return "PORTION_GOAL"
      }
    }
  }

  public enum Health: Int {
    case on
    public func key() -> String {
      switch self {
      case .on:
        return "HEALTH_ON"
      }
    }
  }

  public enum Notification: Int {
    case on, from, to, interval
    public func key() -> String {
      switch self {
      case .on:
        return "NOTIFICATION_ON"
      case .from:
        return "NOTIFICATION_FROM"
      case .to:
        return "NOTIFICATION_TO"
      case .interval:
        return "NOTIFICATION_INTERVAL"
      }
    }
  }
}
