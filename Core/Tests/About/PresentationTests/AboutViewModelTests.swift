import XCTest

import AboutDomain
import PowerAssert
import SwiftlyTest
@testable import AboutPresentation

final class AboutViewModelTests: XCTestCase {
  
  func test_initialAppVersionIsLoading() {
    // given
    let scenario = Scenario()
    
    // then
    #assert(scenario.sut.state.appVersion == .loading)
  }
  
  func test_appVersionIsLoadedCorrectly() async {
    // given
    let scenario = Scenario(appVersion: AppVersion(major: 1, minor: 2, build: 3))
    
    // when
    await test(scenario.sut.$state.map(\.appVersion)) { turbine in
      await turbine.expectInitial(value: .loading)

      // then
      let result = await turbine.value()
      #assert(result == .content("1.2 (3)"))
    }
  }
}

private class Scenario {
  
  let sut: AboutViewModel
  
  init(
    getAppVersion: GetAppVersion = FakeGetAppVersion()
  ) {
    sut = AboutViewModel(getAppVersion: getAppVersion)
  }
  
  convenience init(
    appVersion: AppVersion
  ) {
    self.init(
      getAppVersion: FakeGetAppVersion(appVersion: appVersion)
    )
  }
}
