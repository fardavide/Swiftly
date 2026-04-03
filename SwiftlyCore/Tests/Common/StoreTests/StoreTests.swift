import Testing

import SwiftlyNetwork
import SwiftlyStorage
import SwiftlyUtils
@testable import Store

struct StoreTests {

  // MARK: - shouldFetch = true

  @Test func whenShouldFetch_andFetchSucceeds_returnsSuccess() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.success("fresh"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result.data == "fresh")
    #expect(result.error == nil)
  }

  @Test func whenShouldFetch_andFetchFails_andCacheRecovers_returnsSuccessWithError() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.success("cached"),
      saveCache: { _ in }
    )

    #expect(result.data == "cached")
    #expect(result.error == .network(cause: .unknown))
  }

  @Test func whenShouldFetch_andFetchFails_andCacheFails_returnsError() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result.data == nil)
    #expect(result.error == .network(cause: .unknown))
  }

  @Test func whenShouldFetch_andFetchSucceeds_savesToCache() async {
    var savedValue: String?
    _ = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.success("fresh"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { savedValue = $0 }
    )

    #expect(savedValue == "fresh")
  }

  // MARK: - shouldFetch = false

  @Test func whenShouldNotFetch_andCacheSucceeds_returnsSuccess() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.success("cached"),
      saveCache: { _ in }
    )

    #expect(result.data == "cached")
    #expect(result.error == nil)
  }

  @Test func whenShouldNotFetch_andCacheFails_andFetchRecovers_returnsSuccess() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.success("fresh"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result.data == "fresh")
    #expect(result.error == nil)
  }

  @Test func whenShouldNotFetch_andBothFail_returnsError() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result.data == nil)
    #expect(result.error == .network(cause: .unknown))
  }
}
