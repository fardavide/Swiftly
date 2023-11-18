import Foundation

public extension Double {

  func milliseconds() -> Duration {
    (self / 1000).seconds()
  }

  func seconds() -> Duration {
    Duration(secondsComponent: Int64(self), attosecondsComponent: Int64(self.truncatingRemainder(dividingBy: 1)))
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
    Duration(secondsComponent: Int64(self), attosecondsComponent: 0)
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
