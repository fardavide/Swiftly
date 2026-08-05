import Testing

import SFSafeSymbols
import SwiftUI
import SwiftlyUtils
@testable import Design

/// The point of typing the errors is what the user ends up reading, so that is what these assert on: every
/// cause has to say something of its own. A case answering with another case's copy — or with the catch-all
/// — is the bug this suite exists to catch.
@Suite("ErrorModelTests")
struct ErrorModelTests {

  // MARK: - network
  @Test
  func missingApiKeyBlamesTheBuild() {
    let model = DataError.network(cause: .missingApiKey).toErrorModel()

    #expect(model.title == "This build has no API key, so rates cannot be downloaded")
  }

  @Test
  func invalidApiKeyBlamesTheKey() {
    let model = DataError.network(cause: .invalidApiKey).toErrorModel()

    #expect(model.title == "The rates service rejected the app's API key, it may have expired")
  }

  @Test
  func rateLimitAsksToWait() {
    let model = DataError.network(cause: .rateLimit).toErrorModel()

    #expect(model.title == "The app is over the rates service request limit, please try again later")
  }

  @Test
  func noConnectionBlamesTheConnection() {
    let model = DataError.network(cause: .noConnection).toErrorModel()

    #expect(model.title == "No internet connection")
  }

  @Test
  func timeoutBlamesTheService() {
    let model = DataError.network(cause: .timeout).toErrorModel()

    #expect(model.title == "The rates service took too long to answer")
  }

  /// Asserted through the icon and through two codes not reading alike, rather than against the string:
  /// these two titles interpolate their status code, and `LocalizedStringKey` equality against a plain
  /// literal compares the format key, not the rendered sentence.
  @Test
  func serverErrorIsItsOwnThing() {
    let model = DataError.network(cause: .server(statusCode: 503)).toErrorModel()

    #expect(model.image == .serverRack)
    #expect(model != DataError.network(cause: .server(statusCode: 500)).toErrorModel())
  }

  @Test
  func unexpectedResponseIsItsOwnThing() {
    let model = DataError.network(cause: .unexpectedResponse(statusCode: 418)).toErrorModel()

    #expect(model != DataError.network(cause: .unexpectedResponse(statusCode: 404)).toErrorModel())
    #expect(model != DataError.network(cause: .json).toErrorModel())
  }

  // MARK: - storage
  @Test
  func missingCacheAsksForARefresh() {
    let model = DataError.storage(cause: .noCache).toErrorModel()

    #expect(model.title == "Missing cached data, refresh from network is necessary")
  }

  @Test
  func anUnreadableCacheIsNotTheSameAsAnEmptyOne() {
    let unreadable = DataError.storage(cause: .readFailed).toErrorModel()
    let empty = DataError.storage(cause: .noCache).toErrorModel()

    #expect(unreadable.title != empty.title)
  }

  // MARK: - message
  /// `ErrorView` has room for both lines, so a caller's message becomes the headline and the typed cause
  /// moves below it. Dropping the cause here is what made every failure read the same.
  @Test
  func aMessagePromotesItselfAndKeepsTheCauseAsSubtitle() {
    let model = DataError.network(cause: .noConnection).toErrorModel(message: "Cannot load rates")

    #expect(model.title == "Cannot load rates")
    #expect(model.subtitle == "No internet connection")
  }

  @Test
  func withoutAMessageTheCauseIsTheHeadline() {
    let model = DataError.network(cause: .noConnection).toErrorModel()

    #expect(model.title == "No internet connection")
    #expect(model.subtitle == nil)
  }

  // MARK: - coverage
  @Test
  func noNetworkCauseFallsBackToTheCatchAllCopy() {
    let catchAll = DataError.unknown.toErrorModel().title
    let causes: [DataError.NetworkCause] = [
      .missingApiKey,
      .invalidApiKey,
      .rateLimit,
      .noConnection,
      .timeout,
      .cancelled,
      .server(statusCode: 500),
      .unexpectedResponse(statusCode: 418),
      .json
    ]

    for cause in causes {
      #expect(DataError.network(cause: cause).toErrorModel().title != catchAll)
    }
  }
}
