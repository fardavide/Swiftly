import AboutDomain
import Foundation
import SwiftlyUtils

public final class AboutViewModel: ViewModel {
  public typealias Action = AboutAction
  public typealias State = AboutState
  
  private let getAppName: GetAppName
  private let getAppVersion: GetAppVersion
  @Published public var state: AboutState
  
  init(
    getAppName: GetAppName,
    getAppVersion: GetAppVersion,
    initialState: AboutState = .loading
  ) {
    self.getAppName = getAppName
    self.getAppVersion = getAppVersion
    state = initialState
    Task { load() }
  }
  
  public func send(_ action: AboutAction) {
    switch action {
    case .none: break
    }
  }
  
  private func load() {
    
    let appVersionResult = getAppVersion.run()
      .map { "\($0.major).\($0.minor) (\($0.build))" }
    guard let appVersion = appVersionResult.orNil() else {
      emit { self.state = .error }
      return
    }
 
    let appNameResult = getAppName.run()
      .map(\.value)
    guard let appName = appNameResult.orNil() else {
      emit { self.state = .error }
      return
    }
    
    emit {
      self.state = .content(
        AboutUiModel(
          appName: appName,
          appVersion: appVersion
        )
      )
    }
  }
}

public extension AboutViewModel {
  static let samples = AboutViewModelSamples()
}

public class AboutViewModelSamples {
  public let success = AboutViewModel(
    getAppName: FakeGetAppName(appName: "Swiftly"),
    getAppVersion: FakeGetAppVersion(appVersion: AppVersion(major: 1, minor: 2, build: 3))
  )
  let nameError = AboutViewModel(
    getAppName: FakeGetAppName(appNameResult: .failure(.cantGetAppName)),
    getAppVersion: FakeGetAppVersion(appVersion: AppVersion(major: 1, minor: 2, build: 3))
  )
  let versionError = AboutViewModel(
    getAppName: FakeGetAppName(appName: "Swiftly"),
    getAppVersion: FakeGetAppVersion(appVersionResult: .failure(.cantGetBuild))
  )
}
