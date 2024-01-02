import Foundation
import SwiftlyUtils

public struct AboutState {
  let appVersion: GenericLce<String>
}

extension AboutState {
  static var initial: AboutState {
    AboutState(
      appVersion: .loading
    )
  }
}
