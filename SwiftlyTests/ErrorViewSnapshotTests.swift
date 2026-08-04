import SwiftUI
import Testing

import Design
import SwiftlyUtils

/// Smoke test for the snapshot harness itself.
///
/// `ErrorView` is the only Swiftly view that renders from a plain value: no `Provider` registration,
/// no view model, no network, no clock. It draws an SF Symbol and up to three labels, so a red run
/// here means the harness is broken — never that some product state drifted. That makes it the
/// cheapest end-to-end proof that `assertScreenSnapshot`, the `__Snapshots__` layout and the CI diff
/// report are wired correctly.
///
/// The state under test is the fullest `ErrorView` layout: `toErrorModel(message:)` promotes the
/// message to the title and demotes the built-in copy to the subtitle, and passing a `retry` closure
/// adds the button — symbol, title, subtitle and button in one image.
///
/// Serialized because every assertion takes over the host app's single key window, which two
/// concurrent tests cannot share. swift-testing parallelizes within a bundle regardless of the
/// scheme's `parallelizable = "NO"`, so the trait is doing real work here.
@Suite("ErrorViewSnapshotTests", .serialized)
@MainActor
struct ErrorViewSnapshotTests {

  @Test
  func networkErrorWithRetryMatchesReference() {
    // given
    let view = ErrorView(
      DataError.network(cause: .json).toErrorModel(message: "Cannot fetch currencies"),
      retry: {}
    )

    // then
    assertScreenSnapshot(view, named: "network-json-retry")
  }
}
