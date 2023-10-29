import Foundation

public extension Date {
  
  static func from(_ string: String, formatter: Date.Formatter) -> Date? {
    let formatter = switch formatter {
    case .iso8601: ISO8601DateFormatter()
    }
    return formatter.date(from: string)
  }
  
  /// Create a `date` using given parameters
  /// - Parameters:
  ///   - year: year of the `Date`
  ///   - month: month of the `year`
  ///   - day: 1-index day of the `month`
  ///   - hour: hour of the `day`
  ///   - minute: minute of the `hour`
  ///   - second: second of the `minute`
  ///   - millisecond: millisecond of the `second`
  /// - Returns: Date
  static func of(
    year: Int,
    month: Month,
    day: Int,
    hour: Int = 0,
    minute: Int = 0,
    second: Int = 0,
    millisecond: Int = 0
  ) -> Date {
    assert(day > 0, "day is 1-index value")
    let string = """
    \(year)-\
    \(String(format: "%02d", month.ordinal() + 1))-\
    \(String(format: "%02d", day))T\
    \(String(format: "%02d", hour)):\
    \(String(format: "%02d", minute)):\
    \(String(format: "%02d", second))+\
    \(String(format: "%04d", millisecond))
    """
    return from(string, formatter: .iso8601)!
  }
  
  enum Formatter {
    /*
     Example: 2016-04-14T10:44:00+0000
     */
    case iso8601
  }
  
  enum Month: CaseIterable {
    case jan
    case feb
    case mar
    case apr
    case may
    case jun
    case jul
    case aug
    case sep
    case oct
    case nov
    case dec
  }
}

extension Date.Month {
  
  public func ordinal() -> Self.AllCases.Index {
    return Self.allCases.firstIndex(of: self)!
  }
}
