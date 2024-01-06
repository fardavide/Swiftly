import Foundation

public protocol GetAppVersion {
  
  func run() -> Result<AppVersion, AppVersionError>
}

class RealGetAppVersion: GetAppVersion {
  
  let bundleInfo: BundleInfo
  
  init(bundleInfo: BundleInfo) {
    self.bundleInfo = bundleInfo
  }
  
  func run() -> Result<AppVersion, AppVersionError> {
    guard let appVersionString = bundleInfo.appVersion.orNil() else {
      return .failure(.cantGetVersion)
    }
    guard let appBuildString = bundleInfo.buildNumber.orNil() else {
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
