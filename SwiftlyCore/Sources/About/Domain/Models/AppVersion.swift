public struct AppVersion {
  public let major: Int
  public let minor: Int
  public let patch: Int?
  public let build: Int
  
  public init(
    major: Int,
    minor: Int,
    patch: Int? = nil,
    build: Int
  ) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self.build = build
  }
  
  init(
    version: String,
    build: String
  ) {
    let parts = version.split(separator: ".")
    self.init(
      major: Int(parts[0])!,
      minor: Int(parts[1])!,
      patch: parts.count > 2 ? Int(parts[2])! : nil,
      build: Int(build)!
    )
  }
}

public extension AppVersion {
  var string: String {
    var result = "\(major).\(minor)"
    if let p = patch {
      result += ".\(p)"
    }
    result += " (\(build))"
    return result
  }
}

public enum AppVersionError: Error {
  case cantGetVersion
  case cantGetBuild
}
