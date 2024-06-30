import Foundation
import SwiftlyUtils

public protocol BundleInfo {
  
  var appName: Result<String, GenericError> { get }
  var appVersion: Result<String, GenericError> { get }
  var buildNumber: Result<String, GenericError> { get }
}

final class RealBundleInfo: BundleInfo {
  
  init() {}
  
  var appName: Result<String, GenericError> {
    Result(Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String)
  }
  
  var appVersion: Result<String, GenericError> {
    Result(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
  }
  
  var buildNumber: Result<String, GenericError> {
    Result(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
  }
}

final class FakeBundleInfo: BundleInfo {
  let appName: Result<String, GenericError>
  let appVersion: Result<String, GenericError>
  let buildNumber: Result<String, GenericError>
  
  init(
    appName: Result<String, GenericError>,
    appVersion: Result<String, GenericError>,
    buildNumber: Result<String, GenericError>
  ) {
    self.appName = appName
    self.appVersion = appVersion
    self.buildNumber = buildNumber
  }
  
  convenience init(
    appName: String,
    appVersion: String,
    buildNumber: String
  ) {
    self.init(
      appName: .success(appName),
      appVersion: .success(appVersion),
      buildNumber: .success(buildNumber)
    )
  }
}
