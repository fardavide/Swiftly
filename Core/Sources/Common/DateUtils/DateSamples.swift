import Foundation

public extension Date {
  static let samples = DateSamples()
}

public final class DateSamples {
  public let xmas2023noon = Date.from("2023-12-25T12:44:00+0000", formatter: .iso8601)!
}
