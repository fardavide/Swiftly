import Foundation

public protocol GetAppVersion {
  
  func run() -> Result<AppVersion, AppVersionError>
}

class RealGetAppVersion: GetAppVersion {
  
  func run() -> Result<AppVersion, AppVersionError> {
    guard let appVersionString = getBundleVersion() else {
      return .failure(.unknown)
    }
    let parts = appVersionString.split(separator: ".")
    return .success(
      AppVersion(
        major: Int(parts[0])!,
        minor: Int(parts[1])!
      )
    )
  }
  
  private func getBundleVersion() -> String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
}

public class FakeGetAppVersion: GetAppVersion {
  
  let appVersionResult: Result<AppVersion, AppVersionError>
  
  public init(appVersionResult: Result<AppVersion, AppVersionError> = .failure(.unknown)) {
    self.appVersionResult = appVersionResult
  }
  
  public convenience init(appVersion: AppVersion) {
    self.init(appVersionResult: .success(appVersion))
  }
  
  public func run() -> Result<AppVersion, AppVersionError> {
    appVersionResult
  }
}
