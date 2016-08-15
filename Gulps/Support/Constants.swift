import Foundation

public enum Constants {
  public static func bundle() -> String {
    return "it.fancypixel.BigGulp"
  }

  public enum WatchContext: Int {
    case Current, Date
    public func key() -> String {
      switch self {
      case .Current:
        return "WATCH_CURRENT"
      case .Date:
        return "WATCH_DATE"
      }
    }
  }

  public enum UnitsOfMeasure: Int {
    case Liters, Ounces

    func nameForUnitOfMeasure() -> String {
      switch self {
      case .Liters:
        return NSLocalizedString("Liters", comment: "")
      case .Ounces:
        return NSLocalizedString("Ounces", comment: "")
      }
    }

    func suffixForUnitOfMeasure() -> String {
      switch self {
      case .Liters:
        return "L"
      case .Ounces:
        return "Oz"
      }
    }
  }

  public enum General: Int {
    case UnitOfMeasure, OnboardingShown

    public func key() -> String {
      switch self {
      case .UnitOfMeasure:
        return "UNIT_OF_MEASURE"
      case .OnboardingShown:
        return "ONBOARDING_SHOWN"
      }
    }
  }

  public enum Gulp: Int {
    case Big, Small, Goal
    public func key() -> String {
      switch self {
      case .Big:
        return "GULP_BIG"
      case .Small:
        return "GULP_SMALL"
      case .Goal:
        return "PORTION_GOAL"
      }
    }
  }

  public enum Health: Int {
    case On
    public func key() -> String {
      switch self {
      case .On:
        return "HEALTH_ON"
      }
    }
  }

  public enum Notification: Int {
    case On, From, To, Interval
    public func key() -> String {
      switch self {
      case .On:
        return "NOTIFICATION_ON"
      case .From:
        return "NOTIFICATION_FROM"
      case .To:
        return "NOTIFICATION_TO"
      case .Interval:
        return "NOTIFICATION_INTERVAL"
      }
    }
  }
}
