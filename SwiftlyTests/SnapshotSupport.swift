import SnapshotTesting
import SwiftUI

#if os(iOS)
import UIKit
#endif

// MARK: - Recording baselines
//
// There is no record flag anywhere in this harness. To add or refresh a reference, run the suite
// once: swift-snapshot-testing writes every missing reference under `SwiftlyTests/__Snapshots__/`
// and fails the run. Commit the PNGs, then run a second time — that run must be green. CI never
// records; a missing baseline there is a genuine failure.
//
// MARK: - Why SwiftlyTests is app-hosted
//
// `SwiftlyTests` sets `TEST_HOST`/`BUNDLE_LOADER` to `Swiftly.app`, so the bundle runs inside the
// real app process. That is what `assertScreenSnapshot` needs: it captures through
// `drawHierarchyInKeyWindow`, which draws the view via the process's actual `UIWindow` hierarchy
// rather than an offscreen layer render — so it needs a key window to exist, and the host app is
// what provides one. The capture also takes that window over: it swaps in its own root view
// controller and nils it on teardown, so the app's live UI does not survive the first snapshot.
// Never add a test that depends on the host app's own screens still being up.
//
// The host app is fully launched before the first test runs, which has one consequence worth
// spelling out: `SwiftlyApp.swift:11` already called `Provider.start()`, so a snapshot test must never call
// `Provider.start()` or `Provider.setupPreview(viewModel:)` — both hit
// `fatalError("Provider already initialized")` and abort the whole test process. Copy a `#Preview`
// body into a test and it will take the process down with it. The safe call is
// `getProvider().register { … }` before the view is constructed. `ErrorView` needs no registration
// at all, which is exactly why it is the smoke-test subject.

extension View {

  /// Pins the locale, calendar and time zone so anything date- or number-formatted renders the same
  /// on every machine the snapshots run on.
  ///
  /// This matters for Swiftly in particular: currency amounts and rate timestamps are formatted
  /// through `Locale`/`TimeZone`, so an unpinned environment would bake the recording machine's
  /// region settings into the baselines. The color scheme is not pinned here — `assertScreenSnapshot`
  /// applies it per snapshot, once for light and once for dark.
  func snapshotEnvironment() -> some View {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    return self
      .environment(\.locale, Locale(identifier: "en_US_POSIX"))
      .environment(\.calendar, calendar)
      .environment(\.timeZone, .gmt)
  }
}

#if os(iOS)

/// Fraction of pixels allowed to differ beyond `snapshotPerceptualPrecision` before a snapshot is
/// considered a mismatch — the *area* budget.
///
/// UNTUNED STARTING POINT. Nothing here was measured against a real CI run yet; these two numbers
/// are a deliberate first guess for Swiftly's screens, which are plain SwiftUI (SF Symbols, text,
/// system controls) with no custom shaders. The first red run on CI is the calibration: if it fails
/// on drift that is visually identical in the uploaded diff report, loosen these — do not loosen
/// them to make a real visual change pass.
private let snapshotPrecision: Float = 0.99

/// Per-pixel color tolerance, expressed so that the allowed CIE ΔE is `(1 - value) * 100` — here
/// ΔE 3, a few times the just-noticeable difference and well short of an obvious one.
///
/// UNTUNED STARTING POINT, same caveat as `snapshotPrecision`. This is the knob that absorbs
/// text antialiasing and symbol rasterization differences between a developer's Mac and a CI
/// runner, which is where drift is expected to show up first.
private let snapshotPerceptualPrecision: Float = 0.97

/// Redirects swift-snapshot-testing's failure artifacts — the freshly-rendered image it writes on a
/// mismatch — into a predictable `__SnapshotFailures__/` folder beside the `__Snapshots__/`
/// baselines, unless the caller already pinned `SNAPSHOT_ARTIFACTS`. By default those images land in
/// a per-run temp directory inside the simulator's data container, effectively unreachable. Pinned
/// here, a failing run (local or CI) leaves a tidy tree mirroring the baselines — exactly the
/// screens that didn't match, same relative path — ready to diff by eye against `__Snapshots__/`.
/// On CI the diff report is built straight from this folder. Idempotent: only the first snapshot in
/// the process sets the variable.
private func redirectSnapshotFailureArtifacts(besideBaselinesOf filePath: StaticString) {
  guard ProcessInfo.processInfo.environment["SNAPSHOT_ARTIFACTS"] == nil else { return }
  let testDirectory = URL(fileURLWithPath: "\(filePath)").deletingLastPathComponent()
  let failuresDirectory = testDirectory.appendingPathComponent("__SnapshotFailures__")
  setenv("SNAPSHOT_ARTIFACTS", failuresDirectory.path, 1)
}

/// One entry in the device matrix: a folder-safe name and the layout it renders at.
private struct SnapshotConfig {
  let name: String
  let device: ViewImageConfig
}

/// One entry in the color-scheme matrix.
///
/// The scheme is carried twice, as SwiftUI's `ColorScheme` and as UIKit's `UIUserInterfaceStyle`,
/// because both halves of the capture have to be told about it — see the note in
/// `assertScreenSnapshot`.
private struct SnapshotScheme {
  let name: String
  let colorScheme: ColorScheme
  let interfaceStyle: UIUserInterfaceStyle
}

/// Renders `view` once in a throwaway key window at the snapshot's size and style, to warm the glyph
/// and image caches before the real capture. A cold first render in a fresh process can differ
/// slightly from later ones, which would otherwise surface as a flaky diff.
///
/// The window and hosting controller are deliberately discarded: the library builds its own fresh
/// host for the capture. Do not "optimize" this by warming and then capturing the same host —
/// `ErrorView`'s `.symbolEffect(.pulse)` is only stable because every capture starts from a
/// brand-new host, i.e. from animation phase zero.
@MainActor
private func warmUpRender(_ view: some View, size: CGSize, style: UIUserInterfaceStyle) {
  let host = UIHostingController(rootView: view)
  host.overrideUserInterfaceStyle = style
  host.view.frame = CGRect(origin: .zero, size: size)
  let window = UIWindow(frame: host.view.frame)
  window.overrideUserInterfaceStyle = style
  window.rootViewController = host
  window.makeKeyAndVisible()
  host.view.layoutIfNeeded()
  RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
  window.isHidden = true
  window.rootViewController = nil
}

#endif

/// Renders `view` across Swiftly's snapshot matrix and compares each image against its reference.
///
/// The matrix is iPhone and iPad, portrait and landscape, light and dark — 8 images per call —
/// because the app ships `TARGETED_DEVICE_FAMILY = "1,2"` and adapts its layout to both.
///
/// `name` is the state slug: lowercase kebab, no dots, and never containing `iPhone`, `iPad`,
/// `portrait`, `landscape`, `light` or `dark`. Those tokens are appended here, and the CI diff
/// report reads the last three of them to label each card.
///
/// The whole body is iOS-only. `ViewImageConfig` and `drawHierarchyInKeyWindow` are UIKit concepts,
/// and Swiftly's `SwiftlyTests` target also builds for macOS (`SUPPORTED_PLATFORMS` includes
/// `macosx`); compiling to a no-op there keeps snapshot suites buildable on both platforms while
/// only the iOS destination actually asserts.
@MainActor
func assertScreenSnapshot(
  _ view: some View,
  named name: String,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
) {
  #if os(iOS)
  redirectSnapshotFailureArtifacts(besideBaselinesOf: filePath)
  let base = view.snapshotEnvironment()
  // Stock configs, safe areas included: `.iPhone13(.landscape)` insets 47pt on each side for the
  // notch and 21pt at the bottom for the home indicator, which is what a notched iPhone really
  // shows. Overriding a safe area here would make the baselines disagree with the device.
  let configs: [SnapshotConfig] = [
    SnapshotConfig(name: "iPhone-portrait", device: .iPhone13(.portrait)),
    SnapshotConfig(name: "iPhone-landscape", device: .iPhone13(.landscape)),
    SnapshotConfig(name: "iPad-portrait", device: .iPadPro11(.portrait)),
    SnapshotConfig(name: "iPad-landscape", device: .iPadPro11(.landscape))
  ]
  // The color scheme is forced three times over on purpose: the SwiftUI environment key styles the
  // SwiftUI content, `traits` styles the UIKit-backed chrome the capture draws through, and
  // `overrideUserInterfaceStyle` styles the warm-up window. The environment key alone is not enough.
  let schemes: [SnapshotScheme] = [
    SnapshotScheme(name: "light", colorScheme: .light, interfaceStyle: .light),
    SnapshotScheme(name: "dark", colorScheme: .dark, interfaceStyle: .dark)
  ]
  for scheme in schemes {
    let scene = base.environment(\.colorScheme, scheme.colorScheme)
    let traits = UITraitCollection(userInterfaceStyle: scheme.interfaceStyle)
    for config in configs {
      warmUpRender(
        scene,
        size: config.device.size ?? CGSize(width: 400, height: 800),
        style: scheme.interfaceStyle
      )
      assertSnapshot(
        of: scene,
        as: .image(
          drawHierarchyInKeyWindow: true,
          precision: snapshotPrecision,
          perceptualPrecision: snapshotPerceptualPrecision,
          layout: .device(config: config.device),
          traits: traits
        ),
        named: "\(name).\(config.name).\(scheme.name)",
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
      )
    }
  }
  #endif
}
