public struct AppVersion {
  public let major: Int
  public let minor: Int
  public let build: Int
  
  public init(
    major: Int,
    minor: Int,
    build: Int
  ) {
    self.major = major
    self.minor = minor
    self.build = build
  }
}

public enum AppVersionError: Error {
  case cantGetVersion
  case cantGetBuild
}
