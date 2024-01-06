import Foundation

public protocol GetAppVersion {
  
  func run() -> Result<AppVersion, AppVersionError>
}

class RealGetAppVersion: GetAppVersion {
  
  func run() -> Result<AppVersion, AppVersionError> {
    guard let appVersionString = getBundleVersion() else {
      return .failure(.cantGetVersion)
    }
    guard let appBuildString = getBuildNumber() else {
      return .failure(.cantGetBuild)
    }
    
    let parts = appVersionString.split(separator: ".")
    return .success(
      AppVersion(
        major: Int(parts[0])!,
        minor: Int(parts[1])!,
        build: Int(appBuildString)!
      )
    )
  }
  
  private func getBundleVersion() -> String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
  
  private func getBuildNumber() -> String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }
}

public class FakeGetAppVersion: GetAppVersion {
  
  let appVersionResult: Result<AppVersion, AppVersionError>
  
  public init(appVersionResult: Result<AppVersion, AppVersionError> = .failure(.cantGetVersion)) {
    self.appVersionResult = appVersionResult
  }
  
  public convenience init(appVersion: AppVersion) {
    self.init(appVersionResult: .success(appVersion))
  }
  
  public func run() -> Result<AppVersion, AppVersionError> {
    appVersionResult
  }
}
