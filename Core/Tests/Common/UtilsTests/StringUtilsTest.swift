import Testing

@testable import SwiftlyUtils

struct StringUtilsTest {

  @Test func capitalizeFirst() {
    #expect("hello world. Bye".capitalizedFirst == "Hello world. Bye")
  }
  
  @Test func dotCase_fromCamelCase() {
    #expect("helloWorld".dotCase == "hello.world")
  }
}
