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
    #assert(scenario.sut.state == .loading)
  }
  
  func test_appVersionIsLoadedCorrectly() async {
    // given
    let scenario = Scenario(
      appName: "TestAppName",
      appVersion: AppVersion(major: 1, minor: 2, build: 3)
    )
    
    // when
    await test(scenario.sut.$state) { turbine in
      await turbine.expectInitial(value: .loading)

      // then
      let result = await turbine.value()
      #assert(result.requireContent().appVersion == "1.2 (3)")
    }
  }
  
  func test_appNameIsLoadedCorrectly() async {
    // given
    let scenario = Scenario(
      appName: "TestAppName",
      appVersion: AppVersion(major: 1, minor: 2, build: 3)
    )
    
    // when
    await test(scenario.sut.$state) { turbine in
      await turbine.expectInitial(value: .loading)

      // then
      let result = await turbine.value()
      #assert(result.requireContent().appName == "TestAppName")
    }
  }
}

private class Scenario {
  
  let sut: AboutViewModel
  
  init(
    getAppName: GetAppName = FakeGetAppName(),
    getAppVersion: GetAppVersion = FakeGetAppVersion()
  ) {
    sut = AboutViewModel(
      getAppName: getAppName,
      getAppVersion: getAppVersion
    )
  }
  
  convenience init(
    appName: String,
    appVersion: AppVersion
  ) {
    self.init(
      getAppName: FakeGetAppName(appName: appName),
      getAppVersion: FakeGetAppVersion(appVersion: appVersion)
    )
  }
}
