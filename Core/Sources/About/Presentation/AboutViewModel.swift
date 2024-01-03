import AboutDomain
import Foundation
import SwiftlyUtils

public final class AboutViewModel: ViewModel {
  public typealias Action = AboutAction
  public typealias State = AboutState
  
  private let getAppVersion: GetAppVersion
  @Published public var state: AboutState
  
  init(
    getAppVersion: GetAppVersion,
    initialState: AboutState = AboutState.initial
  ) {
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
    let appVersion: GenericLce<String> = getAppVersion.run()
      .map { "\($0.major).\($0.minor)" }
      .toLce()
    
    emit {
      self.state = AboutState(appVersion: appVersion)
    }
  }
}

public extension AboutViewModel {
  static let samples = AboutViewModelSamples()
}

public class AboutViewModelSamples {
  let success = AboutViewModel(
    getAppVersion: FakeGetAppVersion(appVersion: AppVersion(major: 1, minor: 2))
  )
  let error = AboutViewModel(
    getAppVersion: FakeGetAppVersion(appVersionResult: .failure(.unknown))
  )
}
