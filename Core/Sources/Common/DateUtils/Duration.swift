import Foundation

public struct Duration: Equatable, Comparable {
  let secondsInterval: TimeInterval
}

public extension Duration {
  static prefix func - (duration: Duration) -> Duration {
    Duration(secondsInterval: -duration.secondsInterval)
  }
  static func < (lhs: Duration, rhs: Duration) -> Bool {
    lhs.secondsInterval < rhs.secondsInterval
  }
}

public extension Double {

  func milliseconds() -> Duration {
    (self / 1000).seconds()
  }

  func seconds() -> Duration {
    Duration(secondsInterval: self)
  }

  func minutes() -> Duration {
    (60 * self).seconds()
  }

  func hours() -> Duration {
    (60 * self).minutes()
  }

  func days() -> Duration {
    (24 * self).hours()
  }

  func weeks() -> Duration {
    (7 * self).days()
  }
}

public extension BinaryInteger {

  func milliseconds() -> Duration {
    (Double(self) / 1000).seconds()
  }

  func seconds() -> Duration {
    Duration(secondsInterval: Double(self))
  }

  func minutes() -> Duration {
    (60 * self).seconds()
  }

  func hours() -> Duration {
    (60 * self).minutes()
  }

  func days() -> Duration {
    (24 * self).hours()
  }

  func weeks() -> Duration {
    (7 * self).days()
  }
}
