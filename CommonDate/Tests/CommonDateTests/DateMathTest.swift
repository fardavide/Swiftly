import XCTest
@testable import CommonDate

final class DateMathTest: XCTestCase {
  
  func test_plusDuration() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)
    
    // when
    let result = date + 3.days()
    
    // then
    XCTAssertEqual(
      result, 
      Date.of(year: 2023, month: .nov, day: 1)
    )
  }
  
  func test_minusDuration() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)
    
    // when
    let result = date - 3.days()
    
    // then
    XCTAssertEqual(
      result, 
      Date.of(year: 2023, month: .oct, day: 26)
    )
  }
  
  func test_positiveDistance() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)
    let pastDate = Date.of(year: 2023, month: .oct, day: 26)
    
    // when
    let result = date % pastDate
    
    // then
    XCTAssertEqual(result, 3.days())
  }
  
  func test_positiveNegative() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 26)
    let futureDate = Date.of(year: 2023, month: .oct, day: 29)
    
    // when
    let result = date % futureDate
    
    // then
    XCTAssertEqual(result, -3.days())
  }
}
