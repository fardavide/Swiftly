import Testing

@testable import Provider

struct ProviderTests {
  private let provider = Provider.test()

  @Test
  func whenNotRegistered_errorWithType() {
    // when
    let result = provider.safeGet(Int.self)

    // then
    #expect(result == Result.failure(ProviderError(key: "Int")))
  }

  @Test
  func whenRegistered_rightInstanceIsReturned() {
    // given
    provider.register {
      Child(value: "Hello test")
    }

    // when
    let result = provider.get(Child.self)

    // then
    #expect(result.value == "Hello test")
  }

  @Test
  func whenRegisteredForParent_rightInstanceIsReturned() {
    // given
    provider.register {
      Child(value: "Hello parent") as Parent
    }

    // when
    let result = provider.get(Parent.self)

    // then
    #expect(result.value == "Hello parent")
  }
}

private protocol Parent {
  var value: String { get }
}

private struct Child: Parent {
  let value: String
}
