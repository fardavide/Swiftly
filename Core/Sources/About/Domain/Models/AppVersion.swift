public struct AppVersion {
  public let major: Int
  public let minor: Int
  
  public init(major: Int, minor: Int) {
    self.major = major
    self.minor = minor
  }
}

public enum AppVersionError: Error {
  case unknown
}
