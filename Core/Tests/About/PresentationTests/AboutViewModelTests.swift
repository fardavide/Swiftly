import Testing

import AboutDomain
import SwiftlyTest
@testable import AboutPresentation

@Suite("AboutViewModelTests")
struct AboutViewModelTests {
  
  @Test
  func initialAppVersionIsLoading() {
    // given
    let scenario = Scenario()
    
    // then
    #expect(scenario.sut.state == .loading)
  }
  
  @Test
  func appVersionIsLoadedCorrectly() async throws {
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
      #expect(result.requireContent().appVersion == "1.2 (3)")
    }
  }
  
  @Test
  func appNameIsLoadedCorrectly() async throws {
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
      #expect(result.requireContent().appName == "TestAppName")
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
