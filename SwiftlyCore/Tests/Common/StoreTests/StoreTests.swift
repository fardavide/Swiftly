import Testing

import SwiftlyNetwork
import SwiftlyStorage
import SwiftlyUtils
@testable import Store

struct StoreTests {

  @Test
  func whenFetchSucceeds_returnsSuccess() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.success("fetched"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result == .success("fetched"))
  }

  @Test
  func whenFetchFails_andCacheSucceeds_returnsSuccessWithError() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.success("cached"),
      saveCache: { _ in }
    )

    #expect(result == .successWithError(data: "cached", error: .network(cause: .unknown)))
  }

  @Test
  func whenFetchFails_andCacheFails_returnsError() async {
    let result = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result == .error(.network(cause: .unknown)))
  }

  @Test
  func whenShouldNotFetch_andCacheSucceeds_returnsSuccess() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.success("cached"),
      saveCache: { _ in }
    )

    #expect(result == .success("cached"))
  }

  @Test
  func whenShouldNotFetch_andCacheFails_fetchesThenReturnsSuccess() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.success("fetched"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result == .success("fetched"))
  }

  @Test
  func whenShouldNotFetch_andBothFail_returnsError() async {
    let result = await get(
      shouldFetch: false,
      fetch: Result<String, ApiError>.failure(.unknown),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { _ in }
    )

    #expect(result == .error(.network(cause: .unknown)))
  }

  @Test
  func whenFetchSucceeds_savesCache() async {
    var saved: String?
    _ = await get(
      shouldFetch: true,
      fetch: Result<String, ApiError>.success("fetched"),
      readCache: Result<String, StorageError>.failure(.noCache),
      saveCache: { saved = $0 }
    )

    #expect(saved == "fetched")
  }
}
