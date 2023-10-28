import XCTest
@testable import CommonProvider

final class ProviderTests: XCTestCase {
  private let provider = Provider.instance
  
  func test_whenNotRegistered_errorWithType() throws {
    // when
    let result = provider.safeGet(Int.self)
    
    // then
    XCTAssertEqual(result, Result.failure(ProviderError(key: "Int")))
  }
  
  func test_whenRegistered_rightInstanceIsReturned() throws {
    // given
    struct TestData {
      let value: String
    }
    let data = TestData(value: "Hello test")
    provider.register { data }
    
    // when
    let result = provider.get(TestData.self)
    
    // then
    XCTAssertEqual(result.value, "Hello test")
  }
  
  func test_whenRegisteredForParent_rightInstanceIsReturned() throws {
    // given
    struct Child: TestParent {
      let value: String
    }
    let child = Child(value: "Hello parent")
    provider.register { child as TestParent }
    
    // when
    let result = provider.get(TestParent.self)
    
    // then
    XCTAssertEqual(result.value, "Hello parent")
  }
}

protocol TestParent {
  var value: String { get }
}
