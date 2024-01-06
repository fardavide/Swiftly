import Foundation

public protocol GetAppName {
  
  func run() -> Result<AppName, AppNameError>
}

class RealGetAppName: GetAppName {
  
  let bundleInfo: BundleInfo
  
  init(bundleInfo: BundleInfo) {
    self.bundleInfo = bundleInfo
  }
  
  func run() -> Result<AppName, AppNameError> {
    bundleInfo.appName
      .map { AppName(value: $0) }
      .mapError { _ in .cantGetAppName }
  }
}

public class FakeGetAppName: GetAppName {
  
  let appNameResult: Result<AppName, AppNameError>
  
  public init(appNameResult: Result<AppName, AppNameError> = .failure(.cantGetAppName)) {
    self.appNameResult = appNameResult
  }
  
  public convenience init(appName: AppName) {
    self.init(appNameResult: .success(appName))
  }
  
  public convenience init(appName: String) {
    self.init(appName: AppName(value: appName))
  }
  
  public func run() -> Result<AppName, AppNameError> {
    appNameResult
  }
}
